# Rake tasks used to update the aasm_state of renewing plan year by moving plan year to renewing draft and by publishing it.
# To run rake task: RAILS_ENV=production bundle exec rake migrations:change_renewing_plan_year_aasm_state fein=987654321 plan_year_start_on=02/28/2107
require File.join(Rails.root, "app", "data_migrations", "change_renewing_plan_year_aasm_state")

namespace :migrations do
  desc "Updating the aasm_state of the employer to enrolled"
  ChangeRenewingPlanYearAasmState.define_task :change_renewing_plan_year_aasm_state => :environment
end