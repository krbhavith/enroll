require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

module SponsoredBenefits
  RSpec.describe CensusMembers::PlanDesignCensusEmployeesController, type: :controller, dbclean: :after_each do
    routes { SponsoredBenefits::Engine.routes }

    # This should return the minimal set of attributes required to create a valid
    # CensusMembers::PlanDesignCensusEmployee. As you add validations to CensusMembers::PlanDesignCensusEmployee, be sure to
    # adjust the attributes here as well.
    let(:valid_attributes) {
      skip("Add a hash of attributes valid for your model")
    }

    let(:invalid_attributes) {
      skip("Add a hash of attributes invalid for your model")
    }

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # CensusMembers::PlanDesignCensusEmployeesController. Be sure to keep this updated too.
    let(:valid_session) { {} }

    let!(:organization) { create(:plan_design_organization, :with_application) }
    let!(:benefit_sponsorship) { organization.plan_design_profile.benefit_sponsorships.first }
    let!(:plan_design_application) { benefit_sponsorship.benefit_applications.first }
    let!(:census_employee) { create(:plan_design_census_employee, benefit_application: plan_design_application, employer_profile: organization.plan_design_profile) }

    describe "GET #index" do
      it "returns a success response" do
        get :index, {benefit_application_id: census_employee.benefit_application_id}, valid_session
        expect(response).to be_success
      end
    end

    describe "GET #show" do
      it "returns a success response" do
        plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
        get :show, {:id => plan_design_census_employee.to_param}, valid_session
        expect(response).to be_success
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        get :new, {}, valid_session
        expect(response).to be_success
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
        get :edit, {:id => plan_design_census_employee.to_param}, valid_session
        expect(response).to be_success
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new CensusMembers::PlanDesignCensusEmployee" do
          expect {
            post :create, {:census_members_plan_design_census_employee => valid_attributes}, valid_session
          }.to change(CensusMembers::PlanDesignCensusEmployee, :count).by(1)
        end

        it "redirects to the created census_members_plan_design_census_employee" do
          post :create, {:census_members_plan_design_census_employee => valid_attributes}, valid_session
          expect(response).to redirect_to(CensusMembers::PlanDesignCensusEmployee.last)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, {:census_members_plan_design_census_employee => invalid_attributes}, valid_session
          expect(response).to be_success
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          skip("Add a hash of attributes valid for your model")
        }

        it "updates the requested census_members_plan_design_census_employee" do
          plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
          put :update, {:id => plan_design_census_employee.to_param, :census_members_plan_design_census_employee => new_attributes}, valid_session
          plan_design_census_employee.reload
          skip("Add assertions for updated state")
        end

        it "redirects to the census_members_plan_design_census_employee" do
          plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
          put :update, {:id => plan_design_census_employee.to_param, :census_members_plan_design_census_employee => valid_attributes}, valid_session
          expect(response).to redirect_to(plan_design_census_employee)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'edit' template)" do
          plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
          put :update, {:id => plan_design_census_employee.to_param, :census_members_plan_design_census_employee => invalid_attributes}, valid_session
          expect(response).to be_success
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested census_members_plan_design_census_employee" do
        plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
        expect {
          delete :destroy, {:id => plan_design_census_employee.to_param}, valid_session
        }.to change(CensusMembers::PlanDesignCensusEmployee, :count).by(-1)
      end

      it "redirects to the census_members_plan_design_census_employees list" do
        plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
        delete :destroy, {:id => plan_design_census_employee.to_param}, valid_session
        expect(response).to redirect_to(census_members_plan_design_census_employees_url)
      end
    end

  end
end
