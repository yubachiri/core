require 'rails_helper'

RSpec.feature "StoryStauts", type: :feature do
  include_context "project setup"

  describe "正常系" do

    scenario "ストーリーをアイスボックスからバックログに移動できる" do
      login user
      visit project_path(project)
      post_story story
      in_progress_story = FactoryGirl.build(:story)
      post_story in_progress_story
      saved_in_progress_story = Story.find_by(title: in_progress_story.title)
      within('div#icebox') do
        find("##{saved_in_progress_story.id}_to_backlog").click
      end
      within('div#backlog') do
        all_a_in_backlog = page.all('a')
        expect(page).to have_content in_progress_story.title
      end
      within('div#icebox') do
        expect(page).to have_content story.title
      end

    end

    scenario "ストーリーをバックログからアイスボックスに移動できる" do
      login user
      visit project_path(project)
      post_story story
      in_progress_story = FactoryGirl.build(:story)
      post_story in_progress_story
      saved_in_progress_story = Story.find_by(title: in_progress_story.title)
      within('div#icebox') do
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
    scenario "バックログにストーリーがあり、アイスボックスが空の状態でストーリーを新規追加しても正常に動作する" do
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

    scenario "複数プロジェクトで複雑な操作をしても正常に動作する" do
      # プロジェクトAのアイス・バックにストーリーが存在するとき、
      # プロジェクトBのアイスからバックに移動させると
      # プロジェクトAのストーリーに影響が出てしまう
      login user
      other_project = FactoryGirl.create(:project, user: user)

      visit project_path(project)
      pA_story_A = story
      pA_story_B = FactoryGirl.build(:story)
      post_story pA_story_A
      post_story pA_story_B
      saved_A_story_a = Story.find_by(title: pA_story_A.title)
      saved_A_story_b = Story.find_by(title: pA_story_B.title)

      visit project_path(other_project)
      pB_story_A = FactoryGirl.build(:story)
      pB_story_B = FactoryGirl.build(:story)
      post_story pB_story_A
      post_story pB_story_B
      saved_B_story_a = Story.find_by(title: pB_story_A.title)
      saved_B_story_b = Story.find_by(title: pB_story_B.title)

      # この時点でアイスのストーリーが各２件

      visit project_path project
      within('div#icebox') do
        find("##{saved_A_story_a.id}_to_backlog").click
      end

      visit project_path other_project
      within('div#icebox') do
        find("##{saved_B_story_a.id}_to_backlog").click
      end

      visit project_path project
      within('div#icebox') do
        expect(page).to have_content pA_story_B.title
      end

      within('div#backlog') do
        expect(page).to have_content pA_story_A.title
      end
    end
  end

end
