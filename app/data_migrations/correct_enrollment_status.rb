require File.join(Rails.root, "lib/mongoid_migration_task")

class CorrectEnrollmentStatus < MongoidMigrationTask

  def get_families
    people_ids = Person.where("consumer_role.aasm_state" => {'$ne' => 'unverified'}, "consumer_role.lawful_presence_determination.vlp_authority" => {"$ne" => "curam"}).map(&:id)
    Family.where("family_members.person_id" => {"$in" => people_ids})
  end

  def get_enrollments(family)
    family.households.flat_map(&:hbx_enrollments).select do |hbx_en|
      (!hbx_en.is_shop?) && (!["coverage_canceled", "shopping", "inactive"].include?(hbx_en.aasm_state)) &&
          (hbx_en.terminated_on.blank? || hbx_en.terminated_on >= TimeKeeper.date_of_record)
    end
  end

  def get_members(enrollment)
    enrollment.hbx_enrollment_members.flat_map(&:person).flat_map(&:consumer_role)
  end

  def fix_enrollment(enrollment)
    members = get_members(enrollment)
    if members.any?(&:verification_outstanding?) || members.any?(&:verification_period_ended?)
      enrollment.update_attributes!(is_any_enrollment_member_outstanding: true)
      enrollment.move_to_enrolled! if enrollment.may_move_to_enrolled?
    elsif members.any?(&:ssa_pending?) || members.any?(&:dhs_pending?)
    enrollment.update_attributes!(is_any_enrollment_member_outstanding: false)
     enrollment.move_to_pending!
    elsif members.all?(&:fully_verified?)
    enrollment.update_attributes!(is_any_enrollment_member_outstanding: false)
    enrollment.move_to_enrolled!
    end
  end

  def migrate
    families = get_families
    families.each do |family|
      enrollments = get_enrollments(family)
      enrollments.each do |enrollment|
        fix_enrollment(enrollment)
        enrollment.save!
      end
    end
  end
end