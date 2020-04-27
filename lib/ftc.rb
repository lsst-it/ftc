# @summary
#   The FTC package fetches host configuration from a given Foreman instance
#   and patches Kubernetes configmaps and deployments for a Helm chart deployed
#   Telegraf instance.
module FTC
  require 'ftc/foreman_host'
  require 'ftc/deployment_volume_item'
  require 'ftc/telegraf_configmap'
  require 'ftc/formatter'
end
