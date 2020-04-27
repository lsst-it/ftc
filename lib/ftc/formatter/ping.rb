module FTC
  module Formatter
    # @summary Generate a Telegraf configuration to ping host FQDNs
    class Ping
      attr_reader :count
      attr_reader :deadline
      attr_reader :interval

      def initialize(count: 5, deadline: 5, interval: 1)
        @count = count
        @deadline = deadline
        @interval = interval
      end

      def format(hosts)
        targets = hosts.map do |host|
          {
            count: 5,
            deadline: 5,
            interval: 1,
            urls: host.fqdns,
            #tags: {
            #  subject: host.name
            #}
          }
        end

        TomlRB.dump(inputs: { ping: targets })
      end
    end
  end
end
