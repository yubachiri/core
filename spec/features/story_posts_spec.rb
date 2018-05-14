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

    scenario "プロジェクト参加者はプロジェクトに追加されたストーリーを確認することができる", js:true, focus: true do
      login user
      visit project_path(project)
      click_on project.name
      post_story
      click_on project.name
      expect(page).to have_content @story.title
      # 初期状態ではタイトルのみ表示
      expect(page).to_not have_content @story.description
      click_on @story.title
      sleep 1
      # タイトルをクリックすると詳細がcollapseで表示されることを確認する
      expect(page).to have_content @story.description
    end

  end

  def post_story
    first(:link, "新規ストーリー").click
    fill_in :story_title, with: 'new story'
    fill_in :story_description, with: 'description of new story'
    click_on '作成'
    return @story = Story.new(title:       'new story',
                              description: 'description of new story',
                              project: project)
  end

end
