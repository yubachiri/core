require 'rails_helper'

RSpec.describe "StoryPosts", type: :request do
  include_context "project setup"

  let(:story_hash) { { story: FactoryGirl.attributes_for(:story, project: project) } }

  describe "異常系" do
    xit "プロジェクト参加者以外はストーリーを新規登録できない" do
      login_as user
      puts story_hash
      post project_stories_path(project), params: story_hash
      expect(response).to be_successful
    end
  end
end
