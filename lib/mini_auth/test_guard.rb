# frozen_string_literal: true

class MiniAuth::TestGuard < MiniAuth::Guard
  def attempt!(credentials, remember = nil)
    raise NotImplementedError, 'Testing guard does not support login attempts.'
  end

  def login!(user, remember = nil)
    @user = user
  end

  def logout!
    @user = nil
  end

  def user
    @user ||= nil
  end

  def auth_url
    '/login'
  end
end
