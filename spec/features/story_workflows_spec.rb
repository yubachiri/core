require 'rails_helper'

RSpec.feature "StoryWorkflows", type: :feature do
  include_context "project setup"

  describe "正常系" do
    it "バックログ内でのみ、ストーリーに設定されたワークフローが表示されること" do
      login user
      visit project_path(project)
      temp_story = FactoryGirl.build(:story, workflow: Story.workflows[:start])
      post_story(temp_story)
      story = Story.find_by(title: temp_story.title)
      within('div#icebox') do
        expect(page).to_not have_content 'start'
        find("##{story.id}_to_backlog").click
      end

      # バックログ内で状態を操作できることを確認する
      within('div#backlog') do
        expect(page).to have_content 'start'
        click_link 'start'
      end
      within('div#backlog') do
        expect(page).to have_content 'finish'
        click_link 'finish'
      end
      within('div#backlog') do
        expect(page).to have_content 'accept'
        click_link 'accept'
      end
      within('div#backlog') do
        expect(page).to have_content 'completed'
      end
    end

    it "プロジェクト管理者はストーリーをacceptできる" do
      login user
      visit project_path(project)
      post_story story
      first(:link, 'バックログへ').click
      click_link 'start'
      click_link 'finish'
      click_link 'accept'
      expect(page).to have_content 'completed'
    end
  end

  describe "異常系" do
    it "プロジェクト管理者でなければacceptできない", js:true  do
      login user
      other_user = FactoryGirl.create(:user)

      visit project_path(project)
      click_link project.name
      first(:link, 'メンバー').click
      click_link 'メンバー招待'
      fill_in :search, with: other_user.email
      find_button('招待').click
      sleep 1
      find_button('確定').click
      sleep 1

      login other_user
      visit project_path(project)

      post_story story
      first(:link, 'バックログへ').click
      click_link 'start'
      click_link 'finish'
      click_link 'accept'
      expect(page).to_not have_content 'completed'
      expect(page).to have_content 'accept'
    end
  end

end
