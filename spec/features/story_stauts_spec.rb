require 'rails_helper'

RSpec.feature "StoryStauts", type: :feature do
  include_context "project setup"

  describe "正常系" do

    scenario "ストーリーをアイスボックスからバックログに移動できる", focus: true do
      login user
      visit project_path(project)
      post_story story
      in_progress_story = FactoryGirl.build(:story)
      post_story in_progress_story
      saved_in_progress_story = Story.find_by(title: in_progress_story.title)
      within('div#icebox') do
        click_on in_progress_story.title
        # 進行中にするストーリーの「バックログへ」ボタンをクリックする
        find("##{saved_in_progress_story.id}_to_backlog").click
        all_a_in_icebox = page.all('a')
        expect(all_a_in_icebox[1].text).to eq story.title
      end
      within('div#backlog') do
        all_a_in_backlog = page.all('a')
        expect(all_a_in_backlog[1].text).to eq in_progress_story.title
      end

    end

    scenario "ストーリーをバックログからアイスボックスに移動できる", focus: true do
      login user
      visit project_path(project)
      post_story story
      in_progress_story = FactoryGirl.build(:story)
      post_story in_progress_story
      saved_in_progress_story = Story.find_by(title: in_progress_story.title)
      within('div#icebox') do
        # 進行中にするストーリーの「バックログへ」ボタンをクリックする
        find("##{saved_in_progress_story.id}_to_backlog").click
      end
      # バックログ内にあることを確認
      within('div#backlog') do
        click_link in_progress_story.title
        expect(page).to have_content in_progress_story.title
        expect(page).to have_content in_progress_story.description
        find("##{saved_in_progress_story.id}_to_icebox").click
      end
      # アイスボックス内にあることを確認
      within('div#icebox') do
        click_link in_progress_story.title
        click_on in_progress_story.title
        expect(page).to have_content in_progress_story.title
        expect(page).to have_content in_progress_story.description
      end

    end

  end

  describe "バグ修正" do
    scenario "バックログにストーリーがあり、アイスボックスが空の状態でストーリーを新規追加しても正常に動作する", focus: true do
      login user
      visit project_path(project)
      post_story story

      saved_story = Story.find_by(title: story.title)
      within('div#icebox') do
        find("##{saved_story.id}_to_backlog").click
      end

      new_story = FactoryGirl.build(:story)
      post_story new_story

      within('div#backlog') do
        expect(page).to have_content saved_story.title
      end
      within('div#icebox') do
        expect(page).to have_content new_story.title
      end
    end
  end

end
