module RuleSet
  module HbxEnrollment
    class IndividualMarketVerification
      attr_reader :hbx_enrollment

      def initialize(h_enrollment)
        @hbx_enrollment = h_enrollment
      end

      def applicable?
        (!hbx_enrollment.plan_id.nil?) &&
          hbx_enrollment.affected_by_verifications_made_today? && (!hbx_enrollment.benefit_sponsored?)
      end

      def roles_for_determination
        hbx_enrollment.hbx_enrollment_members.map(&:person).map(&:consumer_role)
      end

      def applicants_for_determination
        application = hbx_enrollment.family.latest_applicable_submitted_application
        return [] if !application
        application.applicants
      end

      def determine_next_state
        return(:move_to_contingent!) if (roles_for_determination.any?(&:verification_outstanding?) || roles_for_determination.any?(&:verification_period_ended?) || applicants_for_determination.any?(&:verification_outstanding?)) && hbx_enrollment.may_move_to_contingent?
        return(:move_to_pending!) if (roles_for_determination.any?(&:ssa_pending?) || roles_for_determination.any?(&:dhs_pending?) || applicants_for_determination.any?(&:income_pending?) || applicants_for_determination.any?(&:mec_pending?)) && hbx_enrollment.may_move_to_pending?
        return(:move_to_enrolled!) if hbx_enrollment.may_move_to_enrolled?
        :do_nothing
      end
    end
  end
end
