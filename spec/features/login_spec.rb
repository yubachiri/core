require 'rails_helper'

RSpec.feature "Logins", type: :feature, focus: true do
  scenario "ゲストは新規会員登録ができる" do
    visit root_path
    click_link '新規登録'
    expect {
      fill_in 'Name', with: 'example'
      fill_in 'Email', with: 'example@email.com'
      fill_in 'Password', with: 'foobar'
      fill_in 'Password confirmation', with: 'foobar'
      click_button '登録'
    }.to change(User, :count).by(1)
  end

  scenario "アプリユーザはログインできる"
end
