require 'rails_helper'

RSpec.feature "StoryStauts", type: :feature do
  include_context "project setup"

  describe "正常系" do

    scenario "ストーリーのステータスによって表示される枠が決まる", focus: true do
      login user
      visit project_path(project)
      post_story story
      in_progress_story = FactoryGirl.build(:story, progress_status: 'in_progress')
      post_story in_progress_story
      saved_in_progress_story = Story.find_by(title: in_progress_story.title)
      within('div#ice-box') do
        click_on in_progress_story.title
        # 進行中にするストーリーの「バックログへ」ボタンをクリックする
        find("##{saved_in_progress_story.id}_to_backlog").click
        all_a_in_icebox = page.all('a')
        expect(all_a_in_icebox[1].text).to eq story.title
      end
      within('div#back-log') do
        all_a_in_backlog = page.all('a')
        expect(all_a_in_backlog[1].text).to eq in_progress_story.title
      end

    end

  end
end
