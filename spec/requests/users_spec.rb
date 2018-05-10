require 'rails_helper'

RSpec.describe "Users", type: :request do

  let(:user) { FactoryGirl.create(:user, :with_project) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:project) { user.projects.first }

  describe "異常系" do
    context "ログイン時" do
      it "参加していないプロジェクトのメンバー一覧は確認できない" do
        login_as other_user
        get project_users_path(project)
        expect(response).to_not be_successful
      end
    end

    context "非ログイン時" do
      it "プロジェクトのメンバー一覧は確認できない" do
        get project_users_path(project)
        expect(response).to_not be_successful
      end
    end
  end
end
