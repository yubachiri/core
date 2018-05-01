require 'rails_helper'

RSpec.describe User, :type => :model do
  it "名前が存在していること" do
    user = FactoryGirl.build(:user)
    user.name = nil
    expect(user).to_not be_valid
  end
end
