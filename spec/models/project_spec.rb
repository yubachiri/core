require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "プロジェクトモデルのバリデーションテスト" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :user_id }
  end
end
