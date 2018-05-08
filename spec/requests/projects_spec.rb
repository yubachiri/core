require 'rails_helper'

RSpec.describe "Projects", type: :request, focus: true do
  describe "異常系", focus: true do
    context "非ログイン時" do
      it "プロジェクト一覧ページにアクセスできない" do
        get projects_path
        expect(response).to_not be_successful
      end

      it "プロジェクト詳細ページにアクセスできない" do
        user = FactoryGirl.create(:user, :with_project)
        project = user.projects.first
        get project_path(project)
        expect(response).to_not be_successful
      end
    end

    context "ログイン時" do
      it "参加していないプロジェクトは閲覧できない" do
        user = FactoryGirl.create(:user, :with_project)
        other_user = FactoryGirl.create(:user)
        login_as other_user
        get project_path(user.projects.first)
        expect(response).to_not be_successful
      end
    end
  end
  
end
