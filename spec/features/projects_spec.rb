require 'rails_helper'

RSpec.feature "Projects", type: :feature, focus: true do

  let(:user) { FactoryGirl.create(:user, :with_project) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:project) { user.projects.first }

  describe "正常系" do

    scenario "自分の参加しているプロジェクト一覧ページからプロジェクトページが確認できる" do
      login user
      visit root_path
      click_link 'プロジェクト一覧'
      click_link project.name
      expect(find_link(project.name)).to be_present
      expect(page).to have_css 'title', visible: "#{project.name} | Core"
    end

    scenario "プロジェクトに参加しているメンバーを確認できる" do
      # あるプロジェクトにユーザ2名が参加している状態を作る
      other_user.project_members << FactoryGirl.create(
        :project_member,
        user:    other_user,
        project: project
      )

      login user
      visit project_path(project)

      click_link 'メンバー'
      expect(page).to have_css 'a', text: user.name
      expect(page).to have_css 'a', text: other_user.name
    end

    scenario "ユーザをプロジェクトに招待できる", js: true do
      login user
      visit root_path
      click_on user.name
      click_link 'プロジェクト一覧'
      click_link project.name
      click_on project.name
      click_link 'メンバー'
      expect {
        click_link 'メンバー招待'
        fill_in :search, with: other_user.email
        click_button '招待'
        click_button '確定'
      }.to change(ProjectMember, :count).by(1)
      expect(page).to have_css 'a', text: other_user.name
    end

  end

  describe "異常系" do

    scenario "プロジェクトに参加していないユーザはプロジェクトの内容を確認できない" do
      login other_user
      visit root_path
      click_link 'プロジェクト一覧'
      # project_nameが含まれる<a></a>がないことを確認する
      expect(page).to_not have_css 'a', text: project.name

      visit project_path(project)
      expect(page).to_not have_css 'title', text: "#{project.name} | Core"
    end

  end

end
