# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'example'
    email 'notexists_address@sample_email_address.com'
    password 'foobar'

    # skip confirmation
    confirmed_at Time.now
  end
end
