require 'rails_helper'
require 'active_support'
require 'active_support/core_ext/date/calculations'

RSpec.feature "StorySegmentations", type: :feature do
  include_context "project setup"

  describe "正常系" do
    it "バックログのストーリーは期間ごとに区切られて表示される", js: true, focus: true do

      # ログイン
      login user
      visit project_path project

      # ストーリー数件準備
      story_first = FactoryGirl.build(:story)
      story_second = FactoryGirl.build(:story)
      story_third = FactoryGirl.build(:story)
      story_fourth = FactoryGirl.build(:story)
      story_fifth = FactoryGirl.build(:story)

      # 全部投稿してバックログへ
      post_and_move_to_backlog story_first
      post_and_move_to_backlog story_second
      post_and_move_to_backlog story_third
      post_and_move_to_backlog story_fourth
      post_and_move_to_backlog story_fifth

      story_first = Story.find_by(title: story_first.title)
      story_second = Story.find_by(title: story_second.title)
      story_third = Story.find_by(title: story_third.title)
      story_fourth = Story.find_by(title: story_fourth.title)
      story_fifth = Story.find_by(title: story_fifth.title)

      # ポイントを設定
      change_point(story_first, 3)
      change_point(story_second, 2)
      change_point(story_third, 5)
      change_point(story_fourth, 1)
      change_point(story_fifth, 1)

      # ベロシティを設定
      # ドロップダウンでやりたい
      find_by_id('velocity').click
      fill_in 'velocity', with: 5
      click_on '適用'

      # 期間ごとに振り分けされていることを確認していく
      within('div#backlog') do
        expect(page).to_not have_content story_first.title
        expect(page).to_not have_content story_third.title
        find("#{Date.today.beginning_of_week} ~ #{Date.today.end_of_week}").click
        expect(page).to have_content story_first.title
        find("#{(Date.today - 1.week).beginning_of_week} ~ #{Date.today.end_of_week}").click
        expect(page).to have_content story_third.title
      end
    end
  end

  # アイスボックスにある引数のストーリーをバックログに移動させる
  def post_and_move_to_backlog(story)
    post_story story
    story = Story.find_by(title: story.title)
    within('div#icebox') do
      find_by_id("#{story.id}_to_backlog").click
    end
  end

  def change_point(story, point)
    click_link story.title
    fill_in "#{story.id}_point", with: point
    find_by_id("#{story.id}_edit_complete_main").click
  end

end
