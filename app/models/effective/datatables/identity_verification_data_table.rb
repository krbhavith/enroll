
module Effective
  module Datatables
    class IdentityVerificationDataTable < Effective::MongoidDatatable
      datatable do
        table_column :name, :label => 'Name', :proc => Proc.new { |row| link_to row.full_name, identity_verification_pending_admin_approval_exchanges_hbx_profiles_path(:person_id => row.id) }, :filter => false, :sortable => false
        table_column :ssn, :label => 'SSN', :proc => Proc.new { |row| truncate(number_to_obscured_ssn(row.ssn))}, :filter => false, :sortable => false
        table_column :dob, :label => 'DOB', :proc => Proc.new { |row| row.dob }, :filter => false, :sortable => false
        table_column :hbx_id, :label => 'HBX ID', :proc => Proc.new { |row| row.hbx_id }, :filter => false, :sortable => false
        table_column :count, :label => 'Count', :width => '100px', :proc => Proc.new { |row| row.primary_family.active_family_members.size  }, :filter => false, :sortable => false
        table_column :document_type, :label => 'Document Type', :proc => Proc.new { |row| document_type(row) }, :filter => false, :sortable => false
        table_column :date_uploaded, :label => "Date Uploaded", :width => '100px', :proc => Proc.new { |row| document_uploaded_date(row) } , :filter => false, :sortable => false
      end

      scopes do
         scope :legal_name, "Hello"
      end

      def collection
        unless  (defined? @families) && @families.present?   #memoize the wrapper class to persist @search_string
          @families = Queries::IdentityVerificationDatatableQuery.new(attributes)
        end
        @families
      end

      def global_search?
        true
      end
      
      def document_type(row)
        if row.consumer_role.identity_validation == "pending" && row.consumer_role.application_validation != "pending"
          return "Identity"
        elsif row.consumer_role.application_validation == "pending" && row.consumer_role.identity_validation != "pending"
          return "Application"
        elsif row.consumer_role.application_validation == "pending" && row.consumer_role.identity_validation == "pending"
          return "Identity/Application"
        end
      end
      
      def document_uploaded_date(row)
        if row.consumer_role.identity_validation == "pending"
          return row.consumer_role.ridp_documents.where(ridp_verification_type:"Identity").last.uploaded_at
        elsif row.consumer_role.application_validation == "pending"
          return row.consumer_role.ridp_documents.where(ridp_verification_type:"Application").last.uploaded_at
        end
      end

    end
  end
end
