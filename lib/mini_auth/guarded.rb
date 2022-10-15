# frozen_string_literal: true

module MiniAuth
  module Guarded
    extend ActiveSupport::Concern

    # @return [MiniAuth::AuthManager]
    def auth_manager
      @auth_manager ||= MiniAuth::AuthManager.make(
        Rails.application.config.mini_auth
      )
    end

    # @return [MiniAuth::Guard]
    def auth_guard(name = nil)
      auth_manager.fetch_guard(request, name)
    end

    def current_user
      auth_guard.user
    end

    class_methods do
      def auth_requests!(guard = nil, **options)
        raise ArgumentError, 'Guard must be a Symbol' unless guard.nil? || guard.is_a?(Symbol)

        before_action(options.slice(:only, :except)) do |c|
          guard_instance = c.auth_guard(guard)

          unless guard_instance.logged_in?
            raise AuthError, 'User must be logged in!', guard_instance.login_url
          end
        end
      end

      def guest_only!(guard = nil, **options)
        raise ArgumentError, 'Guard must be a Symbol' unless guard.nil? || guard.is_a?(Symbol)

        before_action(options.slice(:only, :except)) do |c|
          guard_instance = c.auth_guard(guard)

          unless guard_instance.guest?
            raise GuestError, 'This resource is only available for unauthenticated requests', guard_instance.login_url
          end
        end
      end
    end
  end
end
