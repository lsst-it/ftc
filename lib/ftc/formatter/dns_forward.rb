module FTC
  module Formatter
    # @summary Generate a Telegraf configuration for forward DNS queries
    class DNSForward
      attr_reader :servers

      attr_reader :timeout

      def initialize(servers:, timeout: 5, exclude_fqdns: [])
        @servers = servers
        @timeout = timeout
        @exclude_fqdns = exclude_fqdns.map { |str| Regexp.new(str) }
      end

      def format(hosts)
        targets = hosts.map { |host| format_host(host) }.compact
        TomlRB.dump(inputs: { dns_query: targets })
      end

      def format_host(host)
        filtered_fqdns = host.fqdns
        filtered_fqdns.reject! { |fqdn| @exclude_fqdns.any? { |exclude| fqdn =~ exclude } }
        if filtered_fqdns.any?
            {
              domains: filtered_fqdns,
              servers: @servers,
              timeout: @timeout,
              record_type: "A"
            }
        end
      end
    end
  end
end
