# frozen_string_literal: true

module MiniAuth
  class AuthManager
    attr_reader :default_guard, :guards

    def initialize(default_guard, guards)
      @default_guard = default_guard
      @guards = guards
    end

    # @param [Hash] config
    def self.make(config)
      new(config[:default], config[:guards])
    end

    # @param [ActionDispatch::Request] request
    # @param [MiniAuth::Guard|NilClass] guard
    def fetch_guard(request, guard = nil)
      request.env["mini_auth.guard"] ||= init_guard(request, guard)
    end

    private

    def supports_guard?(guard)
      @guards.any? { |gd| gd[:name] == guard }
    end

    def guard_definition(guard)
      @guards.find { |gd| gd[:name] == guard }
    end

    # @param [ActionDispatch::Request] request
    # @param [MiniAuth::Guard|NilClass] guard
    def init_guard(request, guard = nil)
      guard ||= default_guard
      raise ArgumentError, "Undefined guard #{guard}" unless supports_guard?(guard)

      guard_builder = guard_definition(guard)[:builder]
      guard_builder.call(self, guard, request)
    end
  end
end
