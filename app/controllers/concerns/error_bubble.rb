module ErrorBubble
  def add_document_errors_to_dependent(dependent, document)
    document.errors.each do |k, v|
      dependent.errors.add(k, v)
    end
  end

  def bubble_consumer_role_errors_by_person(person)
    if person.errors.has_key?(:consumer_role)
      person.consumer_role.errors.each do |k, v|
        person.errors.add(k, v)
      end
      if person.consumer_role.errors.has_key?(:vlp_documents)
        person.consumer_role.vlp_documents.select{|v| v.errors.count > 0}.each do |vlp|
          vlp.errors.each do |k, v|
            person.errors.add("#{vlp.subject}: #{k}", v)
          end
        end
      end
      person.errors.delete(:consumer_role)
    end
  end
end
