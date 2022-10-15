# frozen_string_literal: true

module MiniAuth
  class AuthError < RuntimeError
    attr_reader :auth_url

    def initialize(msg, auth_url = nil)
      super(msg)
      @auth_url = auth_url
    end
  end
end
