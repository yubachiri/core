include Warden::Test::Helpers

module FeatureHelper
  def login(user)
    login_as user, scope: :user
  end
end
