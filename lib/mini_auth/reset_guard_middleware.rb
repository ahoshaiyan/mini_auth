# frozen_string_literal: true

module MiniAuth
  class ResetGuardMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    ensure
      MiniAuth::AuthManager.instance.reset_guards!
    end
  end
end
