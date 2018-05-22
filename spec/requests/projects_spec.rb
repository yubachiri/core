require 'rails_helper'

RSpec.describe "Projects", type: :request do
  include_context "project setup"

  describe "正常系" do
    it "管理者ユーザは参加メンバーを外すことができる" do
      temp_project = user.projects.first
      other_user.project_members.build(project: temp_project).save
      login_as user
      expect {
        delete project_project_member_path(temp_project.id, other_user.id)
      }.to change(ProjectMember, :count).by(-1)
    end
  end

  describe "異常系" do

    context "ログイン時" do
      it "参加していないプロジェクトは閲覧できない" do
        login_as other_user
        get project_path(project)
        expect(response).to_not be_successful
      end

      it "管理者ユーザでなければ参加メンバーを外すことはできない" do
        temp_project = user.projects.first
        other_user.project_members.build(project: temp_project).save
        login_as other_user
        expect {
          delete project_project_member_path(temp_project.id, user.id)
        }.to_not change(ProjectMember, :count)
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
