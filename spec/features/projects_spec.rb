require 'rails_helper'

RSpec.feature "Projects", type: :feature do

  scenario "自分の参加しているプロジェクト一覧ページからプロジェクトページが確認できる", focus: true do
    user = FactoryGirl.create(:user, :with_project)
    project_name = user.project_members.first.project.name
    login user
    visit root_path
    click_link 'プロジェクト一覧'
    click_link project_name
    expect(page).to have_css 'title', value: "#{project_name} / projects home"
  end

  scenario "プロジェクトに参加しているユーザしかプロジェクトの内容を確認できない" do
    user = FactoryGirl.create(:user, :with_project)
    other_user = FactoryGirl.create(:user)
    project_name = user.project_members.first.project.name
    login other_user
    visit root_path
    click_link 'プロジェクト一覧'
    # プロジェクト名がないことを期待する
    # click_link project_name
    # expect(page).to have_css 'title', value: "#{project_name} / projects home"
  end

end
