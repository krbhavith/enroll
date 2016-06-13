orgs = Organization.where({:"employer_profile.plan_years" => { 
  :$elemMatch => { 
    :start_on => TimeKeeper.date_of_record.next_month.beginning_of_month, 
    :aasm_state.in => PlanYear::RENEWING_PUBLISHED_STATE }
    }})

count = 0
invlid_renewals = []
orgs.each do |org|
  puts "processing #{org.legal_name}"

  renewal_plan_year = org.employer_profile.plan_years.renewing.first
  elected_plans = renewal_plan_year.benefit_groups.first.elected_plan_ids
  id_list = renewal_plan_year.benefit_groups.collect(&:_id).uniq

  families = Family.where(:"households.hbx_enrollments.benefit_group_id".in => id_list)
  enrollments = families.inject([]) do |enrollments, family|
    enrollments += family.active_household.hbx_enrollments.where(:benefit_group_id.in => id_list).where({ 
      :aasm_state.in => (HbxEnrollment::ENROLLED_STATUSES + HbxEnrollment::RENEWAL_STATUSES)
      })
  end

  puts "found #{enrollments.size} enrollments"
  enrollments.each do |enrollment|
    if !elected_plans.include?(enrollment.plan_id)
      count += 1
      # puts "#{enrollment.plan_id.inspect} not offered by the employer #{elected_plans.inspect}"
      puts enrollment.subscriber.person.full_name
      invlid_renewals << org.legal_name + "---#{org.fein}"
      # break
    end
  end
end

puts count
puts invlid_renewals.uniq