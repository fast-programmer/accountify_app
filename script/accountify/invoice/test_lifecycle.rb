require_relative '../../../config/environment'

# require 'time'
require 'open3'

iam_user_id = 123

iam_tenant_id = 456

current_date = ::Time.now.to_date

organisation_id, _ = Accountify::Organisation.create(
  iam_user_id: iam_user_id,
  iam_tenant_id: iam_tenant_id,
  name: 'Debbies Debts Ltd')

contact_id, _ = Accountify::Contact.create(
  iam_user_id: iam_user_id,
  iam_tenant_id: iam_tenant_id,
  organisation_id: organisation_id,
  first_name: 'John',
  last_name: 'Elliot',
  email: 'john.elliot@tradies.com')

invoice_id, _ = Accountify::Invoice.draft(
  iam_user_id: iam_user_id,
  iam_tenant_id: iam_tenant_id,
  organisation_id: organisation_id,
  contact_id: contact_id,
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
  iam_user_id: iam_user_id,
  iam_tenant_id: iam_tenant_id,
  id: invoice_id,
  contact_id: contact_id,
  organisation_id: organisation_id,
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

Accountify::Invoice.issue(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: invoice_id)

Accountify::Invoice.paid(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: invoice_id)

Accountify::Invoice.void(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: invoice_id)

Accountify::Invoice.delete(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: invoice_id)

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
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation_id)
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
