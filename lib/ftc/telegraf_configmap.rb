require 'diffy'
require 'ftc/k8s_object'

module FTC
  # @summary
  #   The configmap holding the telegraf config file
  class TelegrafConfigmap < FTC::K8sObject
    # @attribute [r] ns
    #   @return [String] The Kubernetes namespace
    attr_reader :ns

    # @attribute [r] name
    #   @return [String] The Telegraf configmap name
    attr_reader :name

    # @attribute[r] key
    #   @return [String] The target configmap key
    attr_reader :key

    def initialize(api, ns, name, key)
      @api = api
      @ns = ns
      @name = name
      @key = key

      @_current = nil
    end

    # @return [String]
    def description
      "ns=#{@ns} configmap/#{@name} key=#{@key}"
    end

    # @return [void]
    def sync!(desired)
      @api
        .api('v1')
        .resource('configmaps', namespace: @ns)
        .merge_patch(@name, data: { @key => desired })

      # Refresh the current state
      fetch!
    end

    # Fetch and set the current configmap content
    # @return [String] The current configmap content
    def fetch!
      cm = @api.api('v1').resource('configmaps', namespace: @ns).get(@name)
      @_current = cm.data[@key]
    end
  end
end
