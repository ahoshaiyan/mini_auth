# frozen_string_literal: true

require 'bcrypt'

class MiniAuth::SessionGuard < MiniAuth::Guard
  REMEMBER_DURATION = 86400 * 30

  attr_reader :name, :model, :request, :session, :login_url

  def self.hash_password(plaintext)
    BCrypt::Password.create(plaintext, cost: 12)
  end

  # @param [String] name
  # @param [Class] model
  # @param [ActionDispatch::Request] request
  # @param [String] login_url
  # @param [Integer] remember_time
  def initialize(name, model, request, login_url, remember_time = REMEMBER_DURATION)
    @name = name
    @model = model
    @request = request
    @login_url = login_url
    @remember_time = remember_time
  end

  def attempt!(credentials, remember = false)
    user = @model.where(credentials.except(:password)).first
    return false if user.blank?

    unless BCrypt::Password.new(user.password).is_password?(credentials[:password])
      return false
    end

    login!(user, remember)
    true
  end

  def login!(user, remember = false)
    @user = user
    @request.reset_session
    @request.session[session_storage_key] = user.id

    if remember
      @user.remember_token = SecureRandom.base58(48)
      @user.save!

      @request.cookie_jar.encrypted.signed[:remember_me] = {
        value: @user.remember_token,
        expires: (Time.now + @remember_time).utc,
        httponly: true
      }
    end

    @user
  end

  def logout!
    @user = nil

    @request.session.delete(session_storage_key)
    @request.cookie_jar.delete(:remember_me)
    @request.reset_session

    nil
  end

  def user
    @user ||= fetch_session_user
  end

  def auth_url
    login_url
  end

  private

  def session_storage_key
    "_mini_auth_session_guard_#{@name.downcase}_#{@model.name.downcase}"
  end

  def fetch_session_user
    if @request.session[session_storage_key].present?
      return @model.where(id: @request.session[session_storage_key]).first
    end

    token = @request.cookie_jar.encrypted.signed[:remember_me]
    unless token.blank?
      user = @model.where(remember_token: token).first

      if user
        login!(user, false)
      else
        @request.cookie_jar.delete(:remember_me)
      end

      return user
    end

    nil
  end
end
