require_dependency "sponsored_benefits/application_controller"

module SponsoredBenefits
  class Organizations::PlanDesignProposalsController < ApplicationController
    include Config::BrokerAgencyHelper
    include DataTablesAdapter

    def index
      @datatable = effective_datatable
    end

    def new
      @plan_design_proposal = SponsoredBenefits::Forms::PlanDesignProposal.new(organization: plan_design_organization)
    end

    def show
      # load relevant quote (not nested)
      # plan_design_proposal
    end

    def edit
      # edit relevant quote (not nested)
    end

    def create
      # create quote for sponsorship
      proposal = SponsoredBenefits::Forms::PlanDesignProposal.new({organization: plan_design_organization}.merge(params.require(:forms_plan_design_proposal)))

      if proposal.save
        flash[:notice] = 'Quote created successfully'
        redirect_to main_app.broker_agencies_profiles_path
      else
        @plan_design_proposal = SponsoredBenefits::Forms::PlanDesignProposal.new(organization: plan_design_organization)
        render :new
      end
    end

    def update
      # update relevant quote (not nested)
      if plan_design_proposal.update_attributes(plan_design_proposal_params)
        redirect_to plan_design_proposal_path(plan_design_proposal._id)
      else
        render :edit
      end
    end

    def destroy
      plan_design_proposal.destroy!
      redirect_to benefit_sponsorship_plan_design_proposals_path(plan_design_proposal.benefit_sponsorship)
    end

    private
      helper_method :customer, :broker, :plan_design_organization

      def broker
        @broker ||= SponsoredBenefits::Organizations::BrokerAgencyProfile.find(plan_design_organization.owner_profile_id)
      end

      def customer
        @customer ||= ::EmployerProfile.find(plan_design_organization.customer_profile_id)
      end

      def effective_datatable
        ::Effective::Datatables::BrokerEmployerQuotesDatatable.new(organization_id: plan_design_organization._id)
      end

      def plan_design_organization
        @plan_design_organization ||= SponsoredBenefits::Organizations::PlanDesignOrganization.find(params[:plan_design_organization_id])
      end

      # def benefit_sponsorship
      #   broker.benefit_sponsorships.first || broker.benefit_sponsorships.new
      # end

      # def benefit_sponsorship_applications
      #   @benefit_sponsorship_applicatios ||= benefit_sponsorship.plan_design_proposals
      # end

      def plan_design_proposal
        @plan_design_proposal ||= Organizations::PlanDesignProposal.find(params[:id])
      end

      def plan_design_proposal_params
        params.require(:plan_design_proposal).permit(
          :title,
          profile: [
            benefit_sponsorship: [
              :initial_enrollment_period,
              :annual_enrollment_period_begin_month_of_year,
              benefit_application: [
                :effective_period,
                :open_enrollment_period
              ]
            ]
          ]
        )
      end
  end
end
