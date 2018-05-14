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
      post_story story
      click_on project.name
      expect(page).to have_content story.title
      # 初期状態ではタイトルのみ表示
      expect(page).to_not have_content story.description
      click_on story.title
      sleep 1
      # タイトルをクリックすると詳細がcollapseで表示されることを確認する
      expect(page).to have_content story.description
    end

    scenario "プロジェクト参加者はすでにあるストーリーを編集することができる", focus: true do
      login user
      story = FactoryGirl.create(:story, project: project)
      visit project_path(project)
      click_on story.title
      fill_in "#{story.id}_title", with: 'edited title'
      fill_in "#{story.id}_description", with: 'edited description'
      first(:button, '編集確定').click
      click_on 'edited title'
      expect(page).to have_content 'edited title'
      expect(page).to have_content 'edited description'
    end

  end

  # ストーリーを渡すと新規作成してくれる
  def post_story(story)
    first(:link, "新規ストーリー").click
    fill_in :story_title, with: story.title
    fill_in :story_description, with: story.description
    click_on '作成'
  end

end
