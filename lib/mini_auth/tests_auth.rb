# frozen_string_literal: true

module MiniAuth
  module TestsAuth
    extend ActiveSupport::Concern

    def after_teardown
      MiniAuth::AuthManager.reset!
      super
    end

    def act_as(user, guard = nil)
      manager = auth_manager
      manager.instance_eval do |s|
        @definitions.unshift({ name: guard || @default_guard, builder: -> (_, _, _) { MiniAuth::TestGuard.new } })
      end

      manager.fetch_guard(ActionDispatch::Request.new({}), guard).login!(user)
    end

    def actor(guard = nil)
      auth_manager.fetch_guard(nil, guard).user
    end

    private

    def auth_manager
      MiniAuth::AuthManager.instance
    end
  end
end
