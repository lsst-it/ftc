module FTC
  module Formatter
    # @summary Generate a Telegraf configuration to ping host FQDNs
    class Ping
      attr_reader :count
      attr_reader :deadline
      attr_reader :interval

      def initialize(count: 5, deadline: 5, interval: 1, exclude_fqdns: [])
        @count = count
        @deadline = deadline
        @interval = interval
        @exclude_fqdns = exclude_fqdns.map { |str| Regexp.new(str) }
      end

      def format(hosts)
        targets = hosts.map { |host| format_host(host) }.compact
        TomlRB.dump(inputs: { ping: targets })
      end

      def format_host(host)
        filtered_fqdns = host.fqdns
        filtered_fqdns.reject! { |fqdn| @exclude_fqdns.any? { |exclude| fqdn =~ exclude } }
        if filtered_fqdns.any?
          {
            count: @count,
            deadline: @deadline,
            interval: @interval,
            urls: filtered_fqdns
          }
        end
      end
    end
  end
end
