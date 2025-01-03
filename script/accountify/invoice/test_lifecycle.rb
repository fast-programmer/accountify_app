require_relative '../../../config/environment'

require 'open3'

user_id = 123

tenant_id = 456

current_date = ::Time.now.to_date

organisation = Accountify::Organisation.create(
  user_id: user_id,
  tenant_id: tenant_id,
  name: 'Debbies Debts Ltd')

contact = Accountify::Contact.create(
  user_id: user_id,
  tenant_id: tenant_id,
  organisation_id: organisation[:id],
  first_name: 'John',
  last_name: 'Elliot',
  email: 'john.elliot@tradies.com')

invoice = Accountify::Invoice.draft(
  user_id: user_id,
  tenant_id: tenant_id,
  organisation_id: organisation[:id],
  contact_id: contact[:id],
  currency_code: "AUD",
  due_date: current_date + 30.days,
  line_items: [{
    description: "Chair",
    unit_amount: {
      amount: BigDecimal("100.00"),
      currency_code: "AUD" },
    quantity: 1
  }, {
    description: "Table",
    unit_amount: {
      amount: BigDecimal("300.00"),
      currency_code: "AUD" },
    quantity: 3 } ])

Accountify::Invoice.update(
  user_id: user_id,
  tenant_id: tenant_id,
  id: invoice[:id],
  contact_id: contact[:id],
  organisation_id: organisation[:id],
  due_date: current_date + 14.days,
  line_items: [{
    description: "Green Jumper",
    unit_amount: {
      amount: BigDecimal("25.00"),
      currency_code: "AUD" },
    quantity: 3
  }, {
    description: "Blue Socks",
    unit_amount: {
      amount: BigDecimal("5.00"),
      currency_code: "AUD" },
    quantity: 4 }])

Accountify::Invoice.issue(user_id: user_id, tenant_id: tenant_id, id: invoice[:id])

Accountify::Invoice.paid(user_id: user_id, tenant_id: tenant_id, id: invoice[:id])

Accountify::Invoice.void(user_id: user_id, tenant_id: tenant_id, id: invoice[:id])

Accountify::Invoice.delete(user_id: user_id, tenant_id: tenant_id, id: invoice[:id])

puts "Starting Sidekiq..."
sidekiq_cmd = "bundle exec sidekiq -r ./config/sidekiq.rb"
sidekiq_process = IO.popen(sidekiq_cmd)

begin
  invoice_status_summary = nil
  attempts = 0
  max_attempts = 10

  while invoice_status_summary.nil? && attempts < max_attempts
    begin
      attempts += 1

      invoice_status_summary = Accountify::InvoiceStatusSummary.find_by_organisation_id(
        tenant_id: tenant_id,
        organisation_id: organisation[:id])
    rescue Accountify::NotFound
      sleep 1

      puts "Invoice status summary not found. Retrying (Attempt #{attempts}/#{max_attempts})..."
    end
  end

  if invoice_status_summary.nil?
    raise Accountify::NotFound, "Invoice status summary not found after #{max_attempts} attempts."
  end
ensure
  puts "Stopping Sidekiq..."

  Process.kill("TERM", sidekiq_process.pid)
  Process.wait(sidekiq_process.pid)
end

# bundle exec ruby script/accountify/invoice/test_lifecycle.rb
# bin/rspec script/accountify/invoice/test_lifecycle.rb
