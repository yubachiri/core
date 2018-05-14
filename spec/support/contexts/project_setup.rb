RSpec.shared_context "project setup" do
  let(:user) { FactoryGirl.create(:user, :with_project) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:project) { user.projects.first }
  let(:story) { FactoryGirl.build(:story)}
end
