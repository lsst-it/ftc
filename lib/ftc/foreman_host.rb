require 'parallel'

module FTC
  # @summary
  #   A Foreman host entry, with associated interfaces
  class ForemanHost
    # @attribute [r] host
    #   @return [Hash] The Foreman host entry
    attr_reader :host

    # @attribute [r] interfaces
    #   @return The Foreman host interfaces
    attr_reader :interfaces

    # Fetch all host definitions and interfaces
    #
    # @param api Apipie::Api
    def self.all(api)
      entries = api.resource(:hosts).call(:index)["results"]

      Parallel.map(entries, in_processes: 16) do |host|
        ForemanHost.query_interfaces(host, api)
      end
    end

    # Given a Foreman host entry, fetch the associated interfaces and generate
    # a new `ForemanHost`.
    #
    # @param host Hash
    # @param api Apipie::Api
    def self.query_interfaces(host, api)
      interfaces = api
                   .resource(:interfaces)
                   .call(:index, host_id: host['id'])
                   .fetch('results')

      new(host, interfaces)
    end

    def initialize(host, interfaces)
      @host = host
      @interfaces = interfaces
    end

    # @return [String]
    def name
      @host['name']
    end

    def managed_interfaces
      interfaces.select { |entry| entry["managed"] }
    end

    # @return Array[Hash] All managed interfaces with IP and MAC addresses
    def configured_interfaces
      managed_interfaces.select { |entry| entry["ip"] && entry["mac"] }
    end

    # @return [Array[String]] All A records assigned to interfaces of this host
    def fqdns
      configured_interfaces.map { |entry| entry["fqdn"] }.compact.sort
    end
  end
end
