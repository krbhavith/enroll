require "rails_helper"
require File.join(Rails.root, "app", "data_migrations", "correct_invalid_benefit_group_assignments_for_employer")

describe CorrectInvalidBenefitGroupAssignmentsForEmployer do

  let(:given_task_name) { "correct_invalid_benefit_group_assignments_for_employer" }
  subject { CorrectInvalidBenefitGroupAssignmentsForEmployer.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do
    it "has the given task name" do
      expect(subject.name).to eql given_task_name
    end
  end

  describe "employer profile with employees present" do

    let!(:employer_profile) { create(:employer_with_planyear, plan_year_state: 'active')}
    let(:benefit_group) { employer_profile.published_plan_year.benefit_groups.first}

    let!(:census_employees){
      FactoryGirl.create :census_employee, :owner, employer_profile: employer_profile
      employee = FactoryGirl.create :census_employee, employer_profile: employer_profile
    }

    let(:census_employee) { employer_profile.census_employees.non_business_owner.first }
    let!(:benefit_group_assignment) {
      census_employee.active_benefit_group_assignment.update(is_active: false) 
      ce = build(:benefit_group_assignment, census_employee: census_employee, start_on: benefit_start_on, end_on: benefit_end_on, aasm_state: "coverage_selected")
      ce.save(:validate => false)
      ce
    }

    let(:benefit_start_on) { benefit_group.start_on }
    let(:benefit_end_on) { nil }

    before(:each) do
      allow(ENV).to receive(:[]).with("fein").and_return(employer_profile.fein)
      allow(ENV).to receive(:[]).with("action").and_return("corect_invalid_bga")
    end

    context "checking benefit group assignments", dbclean: :after_each do

      it "should remove the invalid benefit group assignments" do
        census_employee.active_benefit_group_assignment.benefit_group.delete
        expect(census_employee.active_benefit_group_assignment.present?).to be_truthy
        subject.migrate
        census_employee.reload
        expect(census_employee.active_benefit_group_assignment).to be_nil
      end

      it "should not remove the valid benefit group assignment" do
        subject.migrate
        census_employee.reload
        expect(census_employee.active_benefit_group_assignment.present?).to be_truthy
      end

      context "when benefit group assignment start on is outside the plan year" do
        let(:benefit_start_on) { benefit_group.start_on.prev_day }

        it "should fix start date" do
          expect(census_employee.active_benefit_group_assignment.valid?).to be_falsey
          expect(census_employee.active_benefit_group_assignment.start_on).to eq benefit_start_on
          subject.migrate
          census_employee.reload
          expect(census_employee.active_benefit_group_assignment.valid?).to be_truthy
          expect(census_employee.active_benefit_group_assignment.start_on).to eq benefit_group.start_on
        end
      end

      context "when benefit group assignment end date before start date" do
        let(:benefit_end_on) { benefit_group.start_on.prev_day }

        it "should fix end date" do
          expect(census_employee.active_benefit_group_assignment.valid?).to be_falsey
          expect(census_employee.active_benefit_group_assignment.end_on).to eq benefit_end_on
          subject.migrate
          census_employee.reload
          expect(census_employee.active_benefit_group_assignment.valid?).to be_truthy
          expect(census_employee.active_benefit_group_assignment.end_on).to eq benefit_group.end_on
        end
      end

      context "when benefit group assignment end date is outside the plan year" do
        let(:benefit_end_on) { benefit_group.end_on.next_day }

        it "should fix end date" do
          expect(census_employee.active_benefit_group_assignment.valid?).to be_falsey
          expect(census_employee.active_benefit_group_assignment.end_on).to eq benefit_end_on
          subject.migrate
          census_employee.reload
          expect(census_employee.active_benefit_group_assignment.valid?).to be_truthy
          expect(census_employee.active_benefit_group_assignment.end_on).to eq benefit_group.end_on
        end
      end
      
      context "when benefit group assignment is in coverage selected state and has no hbx_enrollment" do    
        it "should change the state to initialized" do
          expect(census_employee.active_benefit_group_assignment.valid?).to be_falsey
          expect(census_employee.active_benefit_group_assignment.aasm_state).to eq "coverage_selected"
          subject.migrate
          census_employee.reload
          expect(census_employee.active_benefit_group_assignment.valid?).to be_truthy
          expect(census_employee.active_benefit_group_assignment.aasm_state).to eq "initialized"
        end
      end
    end
  end

  describe "employer profile with employees present" do
    let(:family) { FactoryGirl.create(:family, :with_primary_family_member)}
    let(:hbx_enrollment) { FactoryGirl.create(:hbx_enrollment, household: family.active_household, benefit_group_id: benefit_group.id)}
    let(:benefit_group) { plan_year.benefit_groups.first }
    let(:plan_year) { employer_profile.plan_years.first }
    let(:employer_profile) { organization.employer_profile }
    let(:organization) { FactoryGirl.create(:organization, :with_active_plan_year)}
    let(:census_employee) { FactoryGirl.create(:census_employee, employer_profile: employer_profile) }

    before(:each) do
      census_employee.benefit_group_assignments.delete_all
      ENV["id"] = census_employee.id
      ENV["enr_hbx_id"] = hbx_enrollment.hbx_id
      ENV["action"] = "create_new_benefit_group_assignment"      
    end
    context "checking benefit group assignments", dbclean: :after_each do

      it "should build new benefit group assignment" do
        subject.migrate
        census_employee.reload
        expect(census_employee.benefit_group_assignments.where(:benefit_group_id => benefit_group.id).present?).to be_truthy
      end
    end
  end
end
