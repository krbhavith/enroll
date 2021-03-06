require 'rails_helper'

RSpec.describe VlpDocument, :type => :model, :dbclean => :after_each do
  let(:person) {FactoryGirl.create(:person, :with_consumer_role)}
  let(:person2) {FactoryGirl.create(:person, :with_consumer_role)}


  describe "creates person with vlp_docs" do
    it "creates scope for uploaded docs" do
      expect(person.consumer_role.vlp_documents).to exist
    end

    it "returns number of uploaded documents" do
      person2.consumer_role.vlp_documents.first.identifier = "url"
      expect(person2.consumer_role.vlp_documents.uploaded.count).to eq(1)
    end
  end
end
