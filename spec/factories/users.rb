# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "test user #{n}"
    end
    sequence :email do |n|
      "notexists_address#{n}@sample_email_address.com"
    end
    password 'foobar'

    # skip confirmation
    confirmed_at Time.now

    trait :with_project do
      # ユーザ with projects をcreateした場合、自身をオーナーに設定したプロジェクトをもつユーザを作成する
      after(:create) do |user|
        user.project_members << FactoryGirl.create(
          :project_member,
          user:     user,
          project: FactoryGirl.create(:project, user: user),
          admin_flg: true
        )
      end
    end
  end
end
