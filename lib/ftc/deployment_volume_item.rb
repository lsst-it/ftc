require 'ftc/k8s_object'

module FTC
  # @summary
  #   A Telegraf deployment and volume definition matching the telegraf configmap
  #
  # Configmaps cannot have recursive directory entries; in order to utilize
  # the `/etc/telegraf/telegraf.d/` directory we need to tweak the deployment volume
  # definition to mount additional files at subpaths.
  #
  # @note
  #   When a ConfigMap uses explicit paths for files (such as those under `telegraf.d`),
  #   those paths are created as symlinks. Telegraf ignores symlinks by default; as a
  #   workaround run Telegraf with `telegraf --config-directory /etc/telegraf/telegraf.d/`
  #   with the trailing slash.
  class DeploymentVolumeItem < FTC::K8sObject
    # @attribute [r] ns
    #   @return [String] The Kubernetes namespace
    attr_reader :ns

    # @attribute [r] deployment
    #   @return [String] The Telegraf deployment
    attr_reader :deployment

    # @attribute [r] volume
    #   @return [String] The Telegraf volume name
    attr_reader :volume

    # @attribute [r] configmap
    #   @return [String] The Telegraf configmap to mount
    attr_reader :configmap

    # @attribute [r] key
    #   @return [String] The Telegraf configmap key
    attr_reader :key

    # rubocop:disable Metrics/ParameterLists
    def initialize(api, ns, deployment, volume, configmap, key)
      @api = api
      @ns = ns
      @deployment = deployment
      @volume = volume
      @configmap = configmap
      @key = key

      @_current = nil
    end
    # rubocop:enable Metrics/ParameterLists

    # @return [String]
    def description
      "#{@ns} deploy/#{@deployment} volume/#{@volume}/cm/#{@configmap} key=#{@key}"
    end

    # Synchronize the given configmap volume mount item.
    # # Examples
    #
    # ```
    # ns = 'telegraf'
    #
    # # deployment/telegraf-ping
    # deploy = 'telegraf-ping'
    # # default volume name from telegraf chart
    # volume = 'config'
    #
    # # configmap/telegraf-ping
    # configmap = 'telegraf-ping'
    # configmap_key = 'ping.conf'
    #
    # items = DeploymentVolumeItem.new(api, ns, deploy, volume, configmap, configmap_key)
    #
    # items.sync(
    #   key: 'dns.conf',
    #   path: 'telegraf.d/dns.conf'
    # )
    # ```
    #
    # @return [void]
    def sync!(desired)
      # Ensure that the telegraf.conf item is always mounted
      items = [
        {
          key: 'telegraf.conf',
          path: 'telegraf.conf'
        },
        desired
      ].sort_by { |item| item[:path] }

      cm_volume = {
        name: @volume,
        configMap: {
          name: @configmap,
          defaultMode: 420,
          items: items
        }
      }

      patch = {
        spec: {
          template: {
            spec: {
              volumes: [cm_volume]
            }
          }
        }
      }

      @api
        .api('apps/v1')
        .resource('deployments', namespace: @ns)
        .merge_patch(@deployment, patch)

      # Refresh the current state
      fetch!
    end

    # Fetch and set the current deployment volume item
    # @return [String]
    def fetch!
      cm = @api.api('apps/v1').resource('deployments', namespace: @ns).get(@deployment)
      volume = cm.spec.template.spec.volumes.map(&:to_h).find { |h| h[:name] == @volume }
      items = volume.dig(:configMap, :items) || []
      @_current = items.find { |item| item[:key] == @key }
    end
  end
end
