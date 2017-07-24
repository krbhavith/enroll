module PdfTemplates
  class Enrollment
    include Virtus.model

    attribute :enrollees, Array[BasicIndividual]
    attribute :premium, String
    attribute :employee_cost, String
    attribute :phone, String
    attribute :effective_on, Date
    attribute :selected_on, Date
    attribute :aptc_amount, String
    attribute :responsible_amount, String
    attribute :plan, PdfTemplates::Plan
    attribute :coverage_kind, String
    attribute :is_receiving_assistance, Boolean
  end
end
