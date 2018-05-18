# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :story do
    sequence :title do |n|
      "test story #{n}"
    end
    sequence :description do |n|
      "test story's description #{n}"
    end
    sequence :point do |n|
      n
    end
    project nil
    importance nil
    progress_status 'iced'
  end
end
