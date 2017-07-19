module Parsers::Xml::Cv
  class HavenEligibilityDeterminationsParser
    include HappyMapper
    register_namespace 'n1', 'http://openhbx.org/api/terms/1.0'
    tag 'eligibility_determination'

    element :id, String, tag: 'id/n1:id'
    element :maximum_aptc, String
    element :csr_percent, String
    element :aptc_csr_annual_household_income, String
    element :determination_date, Date
    element :aptc_annual_income_limit, String
    element :csr_annual_income_limit, String
    element :created_at, DateTime
    # element :household_state, String
    # element :modified_at, DateTime

    # def to_hash
    #   {
    #     id: id,
    #     household_state: household_state.split('#').last,
    #     maximum_aptc: maximum_aptc,
    #     csr_percent: csr_percent,
    #     determination_date: determination_date,
    #     created_at: created_at,
    #     modified_at: modified_at
    #   }
    # end
  end
end
