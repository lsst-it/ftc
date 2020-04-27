module FTC
  module Formatter
    # @summary Generate a Telegraf configuration for forward DNS queries
    class DNSForward
      attr_reader :servers

      attr_reader :timeout

      def initialize(servers:, timeout: 5)
        @servers = servers
        @timeout = timeout
      end

      def format(hosts)
        targets = hosts.map do |host|
          {
            domains: host.fqdns,
            servers: @servers,
            timeout: @timeout,
            record_type: "A"
          }
        end

        TomlRB.dump(inputs: { dns_query: targets })
      end
    end
  end
end
