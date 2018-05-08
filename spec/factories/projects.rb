# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project, class: Project do
    name 'test project'
    user nil
  end
end
