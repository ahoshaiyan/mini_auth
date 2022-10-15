# frozen_string_literal: true

class MiniAuth::Guard
  # @param [Hash] credentials
  # @param [Boolean] remember
  def attempt!(credentials, remember = false)
    raise NotImplementedError, 'Use implementation instead.'
  end

  # @param [Object] user
  # @param [Boolean] remember
  def login!(user, remember = false)
    raise NotImplementedError, 'Use implementation instead.'
  end

  def logout!
    raise NotImplementedError, 'Use implementation instead.'
  end

  def user
    raise NotImplementedError, 'Use implementation instead.'
  end

  def logged_in?
    user.present?
  end

  def guest?
    !logged_in?
  end

  # @return [String] A URL to authentication path
  def auth_url
    raise NotImplementedError, 'Use implementation instead.'
  end
end
