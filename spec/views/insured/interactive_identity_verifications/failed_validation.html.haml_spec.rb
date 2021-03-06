require "rails_helper"

describe "insured/interactive_identity_verifications/failed_validation" do
  let(:person) { FactoryGirl.create(:person) }
  let(:consumer_role) { FactoryGirl.create(:consumer_role) }
  let(:current_user) {FactoryGirl.create(:user)}
  before :each do
    assign(:person, person)
    assign(:consumer_role, consumer_role)
    assign :verification_transaction_id, "the_transaction_id"
    allow(consumer_role).to receive(:person).and_return person
    allow(person).to receive(:consumer_role).and_return consumer_role
    sign_in current_user
    allow(view).to receive(:policy_helper).and_return(double('FamilyPolicy', updateable?: true))
    allow(view).to receive(:pundit_allow).with(HbxProfile, :can_access_accept_reject_identity_documents?).and_return(true)
    allow(view).to receive(:pundit_allow).with(HbxProfile, :can_delete_identity_application_documents?).and_return(true)
    allow(view).to receive(:pundit_allow).with(HbxProfile, :can_access_accept_reject_paper_application_documents?).and_return(true)
    allow(view).to receive(:ridp_redirection_link).with(person).and_return nil
  end
  it "should show a message about the user failing validation and providing contact info" do
    render :template => "insured/interactive_identity_verifications/failed_validation.html.haml"
    expect(rendered).to include("Your identity could not be confirmed by Experian – the third-party service we use to verify your identity. For your security, you won’t be able to continue your application until you resolve this issue.")
    expect(rendered).to include("Provide your reference number:  the_transaction_id ")
  end

  it "should show a link to invoke fars" do
    render :template => "insured/interactive_identity_verifications/failed_validation.html.haml"
    expect(rendered).to include("CONTINUE APPLICATION")
    expect(rendered).to include("href=\"/insured/interactive_identity_verifications/the_transaction_id\"")
  end
end
