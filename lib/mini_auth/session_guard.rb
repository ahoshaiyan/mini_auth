# frozen_string_literal: true

require 'bcrypt'

class MiniAuth::SessionGuard < MiniAuth::Guard
  attr_reader :name, :model, :request, :session, :login_url

  def self.hash_password(plaintext)
    BCrypt::Password.create(plaintext, cost: 13)
  end

  # @param [String] name
  # @param [Class] model
  # @param [ActionDispatch::Request] request
  # @param [ActionDispatch::Session] session
  # @param [String] login_url
  def initialize(name, model, request, session, login_url)
    @name = name
    @model = model
    @request = request
    @session = session
    @login_url = login_url
  end

  def stateful?
    true
  end

  def attempt!(credentials, remember = false)
    user = @model.where(credentials.except(:password)).first
    return false if user.blank?

    if BCrypt::Password.new(user.password).is_password?(credentials[:password])
      login!(user, remember)
      return true
    end

    false
  end

  def login!(user, remember = false)
    @user = user
    @request.reset_session
    session[session_storage_key] = user.id

    @user
  end

  def logout!
    @user = nil
    session.delete(session_storage_key)
    @request.reset_session

    nil
  end

  def user
    @user ||= @model.where(id: session[session_storage_key]).first
  end

  def auth_url
    login_url
  end

  private

  def session_storage_key
    "_mini_auth_session_guard_#{@name.downcase}_#{@model.name.downcase}"
  end
end
