# frozen_string_literal: true

require 'base64'

class MiniAuth::ApiGuard < MiniAuth::Guard
  attr_reader :name, :model, :request

  # @param [Symbol] name
  # @param [Class] model
  # @param [ActionDispatch::Request] request
  def initialize(name, model, request)
    @name = name
    @model = model
    @request = request
  end

  def attempt!(credentials, remember = nil)
    raise NotImplementedError, 'ApiGuard does not support auth attempt.'
  end

  def login!(user, remember = nil)
    @user = user
  end

  def logout!
    @user = nil
  end

  def user
    @user ||= infer_current_user
  end

  private

  def infer_current_user
    return nil if @infer_tried

    @infer_tried ||= true
    key = key_from_bearer || key_from_basic
    return if key.nil?

    @model.where(api_key: key).first
  end

  def key_from_basic
    header = auth_header
    return nil if header.empty?
    return nil unless header.start_with?('Bearer ')

    header.delete_prefix('Bearer ')
  end

  def key_from_bearer
    header = auth_header
    return nil if header.empty?
    return nil unless header.start_with?('Basic ')

    header = header.delete_prefix('Basic ')
    Base64.decode64(header).split(':')[0]
  end

  def auth_header
    request.headers['Authorization']
  end
end
