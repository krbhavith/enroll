require 'rails_helper'

RSpec.describe InvitationsController do
  let(:user) { instance_double("User") }
  let(:invitation_id) { "an invitation id" }
  let(:invitation) { instance_double(Invitation, :may_claim? => unclaimed) }

  describe "GET claim" do

    before(:each) do
      sign_in(user)
      allow(Invitation).to receive(:find).with(invitation_id).and_return(invitation)
    end

    describe "with an already claimed invitation" do
      let(:unclaimed) { false }

      it "should redirect back to the welcome page with an error" do
        get :claim, :id => invitation_id
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq "Invalid invitation."
      end
    end

    describe "with a valid, unclaimed invitation" do
      let(:unclaimed) { true }

      it "should claim the invitation" do
        expect(invitation).to receive(:claim_invitation!).with(user, controller) do |u, c|
          c.redirect_to root_url
        end
        get :claim, :id => invitation_id
        expect(response).to redirect_to(root_url)
      end
    end

    describe 'with a valid invitation for already existing user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:person) { FactoryGirl.create(:person, user: user) }
      let!(:broker_agency_staff_role) { FactoryGirl.create(:broker_agency_staff_role, aasm_state: 'active', person: person)}
      let(:invitation) { Invitation.new }
      let(:params) { {id: invitation.id, person_id: person.id }}

      before(:each) do
        sign_in(user)
        allow(Invitation).to receive(:find).with(invitation.id).and_return(invitation)
      end

      it 'should redirect to sign in page if already person with user record is present' do
        invitation.source_id = broker_agency_staff_role.id
        get :claim, params
        expect(response).to redirect_to(new_user_session_url(:invitation_id => params[:id]))
      end
    end

  end
end
