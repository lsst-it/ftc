require 'diffy'

module FTC
  # @summary
  #   A Kubernetes object that can be synchronized.
  #
  # @abstract
  class K8sObject
    # @abstract
    def description
      raise NotImplementedError
    end

    # @abstract
    def sync!(_desired)
      raise NotImplementedError
    end

    # @return [Boolean] true if the sync was performed, false otherwise
    def sync(desired)
      if insync?(desired)
        false
      else
        sync!(desired)
        true
      end
    end

    # Is the current object in sync with the desired content?
    #
    # @param desired [String] The desired content for the given Kubernetes object
    def insync?(desired)
      current == desired
    end

    # Generate a diff between the current and desired objects
    def diff(desired)
      Diffy::Diff.new(current, desired, context: 5).to_s(:color)
    end

    # Return or fetch the current object content
    # @return [String]
    def current
      @_current || fetch!
    end
  end
end
