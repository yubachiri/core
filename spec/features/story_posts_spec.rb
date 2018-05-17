require 'rails_helper'

RSpec.feature "StoryPosts", type: :feature do
  LOWEST = -1
  include_context "project setup"

  describe "正常系" do

    scenario "プロジェクト参加者は新規ストーリーを追加できる", focus: true do
      login user
      visit project_path(project)
      click_on project.name
      first(:link, "新規ストーリー").click
      fill_in :story_title, with: 'new story'
      fill_in :story_description, with: 'description of new story'
      select "保留", from: "story_importance"
      expect { click_on '作成' }.to change(Story, :count).by(1)
      expect(page).to have_content 'new story'
    end

    scenario "プロジェクト参加者はプロジェクトに追加されたストーリーを確認することができる", js: true, focus: true do
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

    scenario "プロジェクトのストーリー一覧ではそのストーリーに設定されたポイントを確認できる", focus: true do
      login user
      visit project_path(project)
      post_story story
      within('div#project-main') do
        all_c = page.all('c')
        expect(all_c[0].text).to eq "#{story.point}"
      end
    end

    scenario "プロジェクト参加者はすでにあるストーリーを編集することができる" do
      login user
      story = FactoryGirl.create(:story, project: project, importance: LOWEST)
      visit project_path(project)
      click_on story.title
      fill_in "#{story.id}_title", with: 'edited title'
      fill_in "#{story.id}_description", with: 'edited description'
      select "保留", from: "#{story.id}_importance_#{story.importance}"
      first(:button, '編集確定').click
      click_on 'edited title'
      expect(page).to have_content 'edited title'
      expect(page).to have_content 'edited description'
    end

    scenario "ストーリーは重要度順に並ぶ", js:true do
      login user
      # 一旦４つのストーリーを作る
      # 下→上の順で作る
      story_primary = FactoryGirl.create(:story, project: project, importance: LOWEST)
      story_second  = FactoryGirl.create(:story, project: project, importance: story_primary.id)
      story_third   = FactoryGirl.create(:story, project: project, importance: story_second.id)
      story_fourth  = FactoryGirl.create(:story, project: project, importance: story_third.id)

      visit project_path(project)
      # story_secondの重要度をstory_thirdの一個上にする
      click_on story_second.title
      fill_in "#{story_second.id}_title", with: 'edited title'
      fill_in "#{story_second.id}_description", with: 'edited description'
      select story_third.title, from: "#{story_second.id}_importance_#{story_second.importance}"
      first(:button, '編集確定').click

      visit project_path(project)
      within('div#project-main') do
        all_a = page.all('a')
        expect(all_a[0].text).to eq story_fourth.title
        expect(all_a[1].text).to eq "edited title"
        expect(all_a[2].text).to eq story_third.title
        expect(all_a[3].text).to eq story_primary.title
      end
    end

  end

  describe "バグ修正" do
    scenario "ストーリー編集の際、重要度設定に自身を選択しても正常に動作する", js:true do
      login user
      story = FactoryGirl.create(:story, project: project, importance: LOWEST)
      other_story = FactoryGirl.create(:story, project: project, importance: story.id)
      visit project_path(project)
      click_on story.title
      fill_in "#{story.id}_title", with: 'edited title'
      fill_in "#{story.id}_description", with: 'edited description'
      select story.title, from: "#{story.id}_importance_#{story.importance}"
      first(:button, '編集確定').click
      click_on 'edited title'
      expect(page).to have_content 'edited title'
      expect(page).to have_content 'edited description'
    end

    scenario "重要度最下位のストーリーの重要度を上げても正常に動作する", js:true do
      login user
      story = FactoryGirl.create(:story, project: project, importance: LOWEST)
      other_story = FactoryGirl.create(:story, project: project, importance: story.id)
      visit project_path(project)
      click_on story.title
      fill_in "#{story.id}_title", with: 'edited title'
      fill_in "#{story.id}_description", with: 'edited description'
      select other_story.title, from: "#{story.id}_importance_#{story.importance}"
      first(:button, '編集確定').click
      click_on 'edited title'
      expect(page).to have_content 'edited title'
      expect(page).to have_content 'edited description'
    end

    scenario "重要度最下位のストーリーの重要度を保留に設定しても正常に動作する" do
      login user
      story = FactoryGirl.create(:story, project: project, importance: LOWEST)
      visit project_path(project)
      click_on story.title
      fill_in "#{story.id}_title", with: 'edited title'
      fill_in "#{story.id}_description", with: 'edited description'
      select "保留", from: "#{story.id}_importance_#{story.importance}"
      first(:button, '編集確定').click
      click_on 'edited title'
      expect(page).to have_content 'edited title'
      expect(page).to have_content 'edited description'
    end

    scenario "重要度最下位が存在する時に最下位を新規登録しても正常に動作する", focus: true do
      login user
      story = FactoryGirl.create(:story, project: project, importance: LOWEST)
      visit project_path(project)
      first(:link, "新規ストーリー").click
      fill_in :story_title, with: 'new story'
      fill_in :story_description, with: 'description of new story'
      select "保留", from: "story_importance"
      click_on "作成"
      click_on 'new story'
      expect(page).to have_content 'new story'
      expect(page).to have_content 'description of new story'
    end

    scenario "重要度最下位が存在する時に既存ストーリーの重要度を最下位に変更しても正常に動作する" do
      login user
      story = FactoryGirl.create(:story, project: project, importance: LOWEST)
      other_story = FactoryGirl.create(:story, project: project, importance: story.id)
      visit project_path(project)
      click_on other_story.title
      fill_in "#{other_story.id}_title", with: 'edited title'
      fill_in "#{other_story.id}_description", with: 'edited description'
      select "保留", from: "#{other_story.id}_importance_#{other_story.importance}"
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
    select "保留", from: "story_importance"
    fill_in :point, with: story.point
    click_on '作成'
  end

end
