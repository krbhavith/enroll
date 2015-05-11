require 'watir'
require 'pry'
# load Rails.root + "db/seeds.rb"

module WatirScreenshots
  def screenshot(name = nil)
    if @take_screens
      shot_count = @screen_count.to_s.rjust(3, "0")
      f_name = name.nil? ? shot_count : "#{shot_count}_#{name}"
      @browser.screenshot.save("tmp/#{f_name}.png")
      @screen_count = @screen_count + 1
    end
  end
end

Before "@screenshots" do
  @take_screens = true
end

Before "@keep_browser_open" do
  @keep_browser_open = true
end

Before "@watir" do
  extend WatirScreenshots
  @browser = Watir::Browser.new :chrome, :switches => ["--test-type"]
  @screen_count = 0
end

After "@watir" do
   @keep_browser_open ? @keep_browser_open = false : @browser.close
   @take_screens = false if @take_screens
end

Given(/^I do not exist as a user$/) do
end

Given(/^I have an existing employee record$/) do
end

Given(/^I have an existing person record$/) do
end

When(/^I go to the employee account creation page$/) do
  @browser.goto("http://localhost:3000/")
  @browser.a(:text => "Employee Portal").wait_until_present
  screenshot("start")
  @browser.a(:text => "Employee Portal").click
  @browser.a(:text => "Create account").wait_until_present
  screenshot("employee_portal")
  @browser.a(:text => "Create account").click
end

When(/^I enter my new account information$/) do
  @browser.text_field(:name => "user[password_confirmation]").wait_until_present
  screenshot("create_account")
  @email = "swhite#{rand(100)}@example.com"
  @browser.text_field(:name => "user[email]").set(@email)
  @browser.text_field(:name => "user[password]").set("12345678")
  @browser.text_field(:name => "user[password_confirmation]").set("12345678")
  @browser.input(:value => "Create account").click
end

Then(/^I should be logged in$/) do
  @browser.element(:text => /Welcome! You have signed up successfully./).wait_until_present
  screenshot("logged_in_welcome")
  expect(@browser.element(:text => /Welcome! You have signed up successfully./).visible?).to be_truthy
end

When(/^I go to register as an employee$/) do
  expect(@browser.a(:text => "Continue").visible?).to be_truthy
  @browser.a(:text => "Continue").click
end

Then(/^I should see the employee search page$/) do
  @browser.text_field(:name => "person[first_name]").wait_until_present
  screenshot("employer_search")
  expect(@browser.text_field(:name => "person[first_name]").visible?).to be_truthy
end

When(/^I enter the identifying info of my existing person$/) do
  @browser.text_field(:name => "person[first_name]").set("Soren")
  @browser.text_field(:name => "person[last_name]").set("White")
  @browser.text_field(:name => "person[date_of_birth]").set("08/13/1979")
  @browser.p(:text=> /Personal Information/).click
  @browser.text_field(:name => "person[ssn]").set("670991234")
  screenshot("information_entered")
  @browser.input(:value => "Search Employers", :type => "submit").click
end

Then(/^I should see the matched employee record form$/) do
  @browser.dd(:text => /Acme Inc\./).wait_until_present
  screenshot("employer_search_results")
  expect(@browser.dd(:text => /Acme Inc\./).visible?).to be_truthy
end

When(/^I accept the matched employer$/) do
  @browser.input(:value => /This is my employer/).click
  @browser.input(id: "continue-employer").wait_until_present
  screenshot("update_personal_info")
end

When(/^I complete the matched employee form$/) do
  @browser.text_field(:name => "person[phones_attributes][0][full_phone_number]").set("2025551234")
  @browser.text_field(:name => "person[emails_attributes][1][address]").click
  @browser.input(:id => "continue-employer").click
end

Then(/^I should see the dependents page$/) do
  @browser.p(:text => /Household Information/).wait_until_present
  screenshot("dependents_page")
  expect(@browser.p(:text => /Household Information/).visible?).to be_truthy
end

When(/^I click edit on baby Soren$/) do
  @browser.span(text: "07/03/2014").as(xpath: "./preceding::a[contains(@href, 'edit')]").last.click
end

Then(/^I should see the edit dependent form$/) do
  @browser.input(type: "submit", name: "commit").wait_until_present
end

When(/^I click delete on baby Soren$/) do
  @browser.img(alt: "Member close").click
  @browser.input(type: "submit", name: "commit").wait_while_present(30)
end

Then(/^I should see (.*) dependents$/) do |n|
  n = n.to_i
  expect(@browser.li(class: "dependent_list", index: n)).not_to exist
  expect(@browser.li(class: "dependent_list", index: n - 1)).to exist
end

When(/^I click Add Member$/) do
  @browser.a(text: /Add Member/).click
end

Then(/^I should see the new dependent form$/) do
  raise
end

#    When I click Add Member
#    Then I should see the new dependent form
#    When I enter the identifying info of my daughter
#    When I click confirm member
#    Then I should see 3 dependents

When(/^I click continue on the dependents page$/) do
  @browser.a(:text => "Continue", :href => /group_selection\/new/).click
end

Then(/^I should see the group selection page$/) do
  @browser.form(:action => /group_selection\/create/).wait_until_present
  screenshot("group_selection")
end

When(/^I click continue on the group selection page$/) do
  @browser.input(:value=> /Continue/).click
end

Then(/^I should see the plan shopping welcome page$/) do
  @browser.p(:text => /Select a Plan/).wait_until_present
  screenshot("plan_shopping_welcome")
  expect(@browser.p(:text => /Select a Plan/).visible?).to be_truthy
end

When(/^I click continue on the plan shopping welcome page$/) do
  @browser.a(:text => "Continue").click
end

Then(/^I should see the list of plans$/) do
  @browser.a(:text => "Select").wait_until_present
  screenshot("plan_shopping")
end

When(/^I select a plan on the plan shopping page$/) do
  @browser.a(:text => "Select").click
end

Then(/^I should see the coverage summary page$/) do
  @browser.a(href: /\/plan_shopping\/checkout/, class: "btn-continue").wait_until_present
  screenshot("summary_page")
  expect(@browser.a(href: /\/plan_shopping\/checkout/, class: "btn-continue").visible?).to be_truthy
end

When(/^I confirm on the coverage summary page$/) do
  @browser.a(:text => "Confirm").click
end

Then(/^I should see the "my account" page$/) do
  @browser.span(:text => "Household").wait_until_present
  screenshot("my_account_page")
  expect(@browser.span(:text => "Household").visible?).to be_truthy
end
