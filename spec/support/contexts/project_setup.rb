RSpec.shared_context "project setup" do
  let(:user) { FactoryGirl.create(:user, :with_project) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:project) { user.projects.first }
  let(:story) { FactoryGirl.build(:story) }

  # ストーリーを渡すと新規作成してくれる
  def post_story(story)
    first(:link, "新規ストーリー").click
    fill_in :story_title, with: story.title
    fill_in :story_description, with: story.description
    select "保留", from: "story_importance"
    fill_in :point, with: story.point
    click_on '作成'
  end
end
