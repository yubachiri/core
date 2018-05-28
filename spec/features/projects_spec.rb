require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  include_context "project setup"

  describe "正常系" do

    scenario "自分の参加しているプロジェクト一覧ページからプロジェクトページが確認できる" do
      login user
      visit root_path
      click_link 'プロジェクト一覧'
      click_link project.name
      expect(find_link(project.name)).to be_present
      expect(page).to have_css 'title', visible: "#{project.name} | Core"
    end

    scenario "プロジェクトに参加しているメンバーを確認できる"do
      # あるプロジェクトにユーザ2名が参加している状態を作る
      other_user.project_members << FactoryGirl.create(
        :project_member,
        user:    other_user,
        project: project
      )

      login user
      visit project_path(project)

      first(:link, "メンバー").click
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
      first(:link, "メンバー").click
      expect {
        click_on 'メンバー招待'
        fill_in :search, with: other_user.email
        find_button('招待').click
        sleep 1
        find_button('確定').click
        sleep 1
      }.to change(ProjectMember, :count).by(1)
      expect(page).to have_css 'a', text: other_user.name
    end

    scenario "管理者ユーザはプロジェクト参加ユーザを外すことができる", js: true do
      login user
      add_member project, other_user
      visit root_path
      click_on user.name
      click_link 'プロジェクト一覧'
      click_link project.name
      click_on project.name
      first(:link, "メンバー").click
      click_on other_user.name
      expect { click_on 'プロジェクトから外す' }.to change(ProjectMember, :count).by(-1)
    end

    scenario "ユーザは新規プロジェクトを作成できる",js: true do
      login user
      visit root_path
      click_on user.name
      click_on '新規プロジェクト'
      fill_in :project_name, with: 'new project'
      expect{click_on '作成'}.to change(Project, :count).by(1)

      new_project = Project.find_by(name: 'new project')
      new_project_member = user.project_members.find_by(project: new_project)
      expect(new_project.user_id).to eq(user.id)
      expect(new_project_member).to be_present
      expect(new_project_member.admin_flg).to be_truthy
      expect(page).to have_content new_project.name
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

  def add_member(project, user)
    visit project_users_path(project)
    click_link 'メンバー招待'
    fill_in :search, with: user.email
    find_button('招待').click
    sleep 2
    find_button('確定').click
    sleep 2
  end

end
