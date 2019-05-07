require 'rails_helper'

RSpec.describe "ApplicationFactory" do
  describe 'copy_application' do
    subject do
      FinancialAssistance::Factories::ApplicationFactory.new(application)
    end

    context 'when application has only one applicant and one family member' do
      include_examples 'submitted application with one member and one applicant'
      context 'before copy application' do
        it 'should have one application' do
          expect(family.applications.count).to eq 1
        end
      end

      context 'after copy application' do
        before do
          subject.copy_application
          @draft_application = family.application_in_progress
        end
        it 'should have 2 application' do
          expect(family.applications.count).to eq 2
        end

        it 'should have one draft application' do
          expect(@draft_application.aasm_state).to eq('draft')
        end

        it 'copied application should be valid' do
          expect(@draft_application.valid?).to eq true
        end

        it 'should not match hbx id for both the applications' do
          expect(family.latest_submitted_application.hbx_id).not_to eq family.application_in_progress.hbx_id
        end

        it 'should have one applicant' do
          expect(@draft_application.active_applicants.count).to eq 1
        end

        it 'should have one income' do
          incomes = @draft_application.applicants.first.incomes
          expect(incomes.count).to eq 1
        end

        it 'should have one benefit' do
          benefits = @draft_application.applicants.first.benefits
          expect(benefits.count).to eq 1
        end

        it 'should have one deduction' do
          deductions = @draft_application.applicants.first.deductions
          expect(deductions.count).to eq 1
        end

        it 'should not have assisted verifications' do
          assisted_verifications = @draft_application.applicants.first.assisted_verifications
          expect(assisted_verifications.count).to eq 0
        end
      end
    end

    context 'when application has one applicant and two family members' do
      include_examples 'submitted application with two active members and one applicant'

      context 'after copy application' do
        before do
          subject.copy_application
          @draft_application = family.application_in_progress
        end

        it 'should have two active applicants' do
          expect(@draft_application.active_applicants.count).to eq 2
        end
      end
    end


    context 'when application has only two applicants and one family member' do
      include_examples 'submitted application with one active member and two applicant'

      context 'after copy application' do
        before do
          subject.copy_application
          @draft_application = family.application_in_progress
        end

        it 'should have one active applicant' do
          expect(@draft_application.active_applicants.count).to eq 1
        end
      end
    end
  end

  describe 'sync_family_members_with_applicants' do
    subject do
      FinancialAssistance::Factories::ApplicationFactory.new(application)
    end

    context 'when application has only one applicant and one family member' do
      include_examples 'submitted application with two active members and one applicant'
      before do
        application.update_attributes(aasm_state: 'draft', submitted_at: nil)
        application.reload
      end

      context 'before sync applicants' do
        it 'should have one applicant' do
          expect(application.active_applicants.count).to eq 1
        end
      end

      context 'after sync applicants' do
        it 'should have two applicants' do
          subject.sync_family_members_with_applicants
          expect(application.active_applicants.count).to eq 2
        end
      end
    end
  end
end