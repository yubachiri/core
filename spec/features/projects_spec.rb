require 'rails_helper'

RSpec.feature "Projects", type: :feature, focus: true do

  scenario "自分の参加しているプロジェクト一覧ページからプロジェクトページが確認できる", focus: true do
    user = FactoryGirl.create(:user, :with_project)
    project_name = user.project_members.first.project.name
    login user
    visit root_path
    click_link 'プロジェクト一覧'
    click_link project_name
    expect(find_link(project_name)).to be_present
    expect(page).to have_css 'title', visible: "#{project_name} | Core"
  end

  scenario "プロジェクトに参加しているユーザしかプロジェクトの内容を確認できない" do
    user = FactoryGirl.create(:user, :with_project)
    other_user = FactoryGirl.create(:user)
    project = user.project_members.first.project
    login other_user
    visit root_path
    click_link 'プロジェクト一覧'
    # project_nameが含まれる<a></a>がないことを確認する
    expect(page).to_not have_css 'a', text: project.name

    visit project_path(project)
    expect(page).to_not have_css 'title', text: "#{project.name} | Core"
  end

end
