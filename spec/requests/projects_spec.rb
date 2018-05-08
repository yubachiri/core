require 'rails_helper'

RSpec.describe "Projects", type: :request do
  describe "異常系", focus: true do
    it "ログインしていなければプロジェクト一覧ページにアクセスできない" do
      get projects_path
      expect(response).to have_http_status(404)
    end
  end
end
