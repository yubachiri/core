require 'rails_helper'

RSpec.describe "Projects", type: :request do

  let(:user) { FactoryGirl.create(:user, :with_project) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:project) { user.projects.first }

  describe "異常系" do

    context "ログイン時" do
      it "参加していないプロジェクトは閲覧できない" do
        login_as other_user
        get project_path(user.projects.first)
        expect(response).to_not be_successful
      end
    end

    context "非ログイン時" do
      it "プロジェクト一覧ページにアクセスできない" do
        get projects_path
        expect(response).to_not be_successful
      end

      it "プロジェクト詳細ページにアクセスできない" do
        get project_path(project)
        expect(response).to_not be_successful
      end
    end

  end

end
