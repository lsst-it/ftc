module FTC
  # @summary
  #   Formatters take a list of foreman hosts and generate a Telegraf
  #   configuration to monitor said hosts.
  module Formatter
    require_relative 'formatter/ping'
    require_relative 'formatter/dns_forward'
  end
end
