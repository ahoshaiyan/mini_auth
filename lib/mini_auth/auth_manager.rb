# frozen_string_literal: true

module MiniAuth
  Semaphore = Mutex.new

  class AuthManager
    attr_reader :default_guard, :definitions

    def initialize(default_guard, definitions)
      @default_guard = default_guard
      @definitions = definitions.clone(freeze: false)
      @guards = {}
    end

    # @param [Hash] config
    def self.make(config)
      new(config[:default], config[:guards])
    end

    # @return [MiniAuth::AuthManager]
    def self.instance
      Semaphore.synchronize do
        @@instances ||= {}
        @@instances[Thread.current.__id__] ||= make(Rails.application.config.mini_auth)
      end
    end

    def self.reset!
      Semaphore.synchronize do
        @@instances ||= {}
        @@instances.delete(Thread.current.__id__)
      end
    end

    def reset_guards!
      @guards = {}
    end

    # @param [ActionDispatch::Request] request
    # @param [MiniAuth::Guard|NilClass] guard
    # @return [MiniAuth::Guard]
    def fetch_guard(request, guard = nil)
      guard = default_guard if guard.nil?
      @guards[guard] ||= init_guard(request, guard)
    end

    private

    def supports_guard?(guard)
      @definitions.any? { |gd| gd[:name] == guard }
    end

    def guard_definition(guard)
      @definitions.find { |gd| gd[:name] == guard }
    end

    # @param [ActionDispatch::Request] request
    # @param [MiniAuth::Guard|NilClass] guard
    def init_guard(request, guard)
      raise ArgumentError, "Undefined guard #{guard}" unless supports_guard?(guard)

      guard_builder = guard_definition(guard)[:builder]
      guard_builder.call(self, guard, request)
    end
  end
end
