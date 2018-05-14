require 'rails_helper'

RSpec.feature "StoryPosts", type: :feature do
  include_context "project setup"

  describe "正常系" do

    scenario "プロジェクト参加者は新規ストーリーを追加できる" do
      login user
      visit project_path(project)
      click_on project.name
      first(:link, "新規ストーリー").click
      fill_in :story_title, with: 'new story'
      fill_in :story_description, with: 'description of new story'
      expect { click_on '作成' }.to change(Story, :count).by(1)
      expect(page).to have_content 'new story'
    end
  end
end
