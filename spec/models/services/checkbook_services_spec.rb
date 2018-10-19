require 'rails_helper'
include ApplicationHelper

describe Services::CheckbookServices::PlanComparision do

  let(:census_employee) { FactoryGirl.build(:census_employee, first_name: person.first_name, last_name: person.last_name, dob: person.dob, ssn: person.ssn, employee_role_id: employee_role.id)}
  let(:household) { FactoryGirl.create(:household, family: person.primary_family)}
  let(:employee_role) { FactoryGirl.create(:employee_role, person: person)}
  let(:person) { FactoryGirl.create(:person, :with_family)}
  let!(:hbx_enrollment) { FactoryGirl.create(:hbx_enrollment, household: census_employee.employee_role.person.primary_family.households.first, employee_role_id: employee_role.id)}
  let!(:consumer_person) { FactoryGirl.create(:person, :with_consumer_role) }
  let!(:family) { FactoryGirl.create(:family, :with_primary_family_member, person: consumer_person) }
  let!(:hbx_enrollment1) { FactoryGirl.create(:hbx_enrollment, kind: "individual", consumer_role_id: consumer_person.consumer_role.id, household: family.active_household)}

  describe "when employee is not congress" do
    subject { Services::CheckbookServices::PlanComparision.new(hbx_enrollment,false) }
    let(:result) {double("HttpResponse" ,:parsed_response =>{"URL" => "http://checkbook_url"})}

    it "should generate non-congressional link" do
      if plan_match_dc
        allow(subject).to receive(:construct_body_shop).and_return({})
        allow(HTTParty).to receive(:post).with("https://staging.checkbookhealth.org/shop/dc/api/",
          {:body=>"{}", :headers=>{"Content-Type"=>"application/json"}}).
          and_return(result)
        expect(subject.generate_url).to eq "http://checkbook_url"
      end
    end
  end

  describe "when user is consumer" do
    subject { Services::CheckbookServices::PlanComparision.new(hbx_enrollment1,false) }
    let(:checkbook_url) {"http://checkbook_url"}
    let(:result) {double("HttpResponse" ,:parsed_response =>{"URL" => checkbook_url})}

    it "should generate consumer link" do
        if plan_match_dc
          allow(subject).to receive(:construct_body_ivl).and_return({})
          allow(HTTParty).to receive(:post).with(Settings.consumer_checkbook_services.base_url,
            {:body=>"{}", :headers=>{"Content-Type"=>"application/json"}}).
            and_return(result)
          expect(subject.generate_url).to eq checkbook_url
        end
      end
  end

  describe "#csr_value" do
    subject { Services::CheckbookServices::PlanComparision.new(hbx_enrollment,false) }
    context "when active household is present" do 
      let(:tax_household) {FactoryGirl.create(:tax_household, household: household, effective_starting_on: Date.new(TimeKeeper.date_of_record.year,1,1), effective_ending_on: nil)}
      let(:sample_max_aptc_1) {511.78}
      let(:sample_csr_percent_1) {87}
      let(:eligibility_determination_1) {EligibilityDetermination.new(determined_at: TimeKeeper.date_of_record.beginning_of_year, max_aptc: sample_max_aptc_1, csr_percent_as_integer: sample_csr_percent_1 )}

      it "should return correct csr percentage" do
        allow(tax_household).to receive(:eligibility_determinations).and_return [eligibility_determination_1]
        allow(hbx_enrollment).to receive_message_chain(:household,:latest_active_tax_household_with_year).and_return(tax_household)
        expect(subject.csr_value).to eq tax_household.latest_eligibility_determination.csr_percent_as_integer
      end
    end
     context "when active household not present" do 
      it "should return -01" do
        allow(hbx_enrollment).to receive_message_chain(:household,:latest_active_tax_household_with_year).and_return(nil)
        expect(subject.csr_value).to eq "-01"
      end
    end
   end

  describe "#aptc_value  " do
    subject { Services::CheckbookServices::PlanComparision.new(hbx_enrollment,true) }
    context "when active household is present" do 
      let(:tax_household) {FactoryGirl.create(:tax_household, household: household, effective_starting_on: Date.new(TimeKeeper.date_of_record.year,1,1), effective_ending_on: nil)}
      let(:sample_max_aptc_1) {511.78}
      let(:sample_csr_percent_1) {87}
      let(:eligibility_determination_1) {EligibilityDetermination.new(determined_at: TimeKeeper.date_of_record.beginning_of_year, max_aptc: sample_max_aptc_1, csr_percent_as_integer: sample_csr_percent_1 )}

      it "should return max aptc" do
        allow(tax_household).to receive(:eligibility_determinations).and_return [eligibility_determination_1]
        allow(hbx_enrollment).to receive_message_chain(:household,:latest_active_tax_household_with_year).and_return(tax_household)
        expect(subject.aptc_value).to eq tax_household.latest_eligibility_determination.max_aptc
      end
    end
     context "when active household  not present" do 
      it "should return max 000" do
        allow(hbx_enrollment).to receive_message_chain(:household,:latest_active_tax_household_with_year).and_return(nil)
        expect(subject.aptc_value).to eq "000"
      end
    end
  end

  describe "when employee is congress member" do
    subject { Services::CheckbookServices::PlanComparision.new(hbx_enrollment,true) }

    it "should generate congressional url" do
     if plan_match_dc
       allow(subject).to receive(:construct_body_shop).and_return({})
       expect(subject.generate_url).to eq("https://dc.checkbookhealth.org/congress/dc/")
      end
    end
  end
end
