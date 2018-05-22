require 'rails_helper'

RSpec.describe Story, type: :model do
  include_context "project setup"

  let(:invalid_story){
    FactoryGirl.build(:story,
      title: 'test',
      description: 'test description',
      project: project,
      importance: story.id,
      point: 3
    )
  }

  it "タイトルが存在していること" do
    invalid_story.title = nil
    expect(invalid_story).to_not be_valid
  end

  it "プロジェクトに属していること" do
    invalid_story.project = nil
    expect(invalid_story).to_not be_valid
  end

  it "ポイントは３桁以内であること" do
    invalid_story.point = 1000
    expect(invalid_story).to_not be_valid
  end

  it "ポイントは半角数値のみであること" do
    invalid_story.point = 'a１'
    expect(invalid_story).to_not be_valid
  end

end
