class EventCreatedJob
  include Sidekiq::Job

  sidekiq_options queue: 'reporting', retry: false

  def perform(args)
    case args['type']
    when 'Accountify::Organisation::CreatedEvent'
      Accountify::InvoiceStatusSummary::GenerateJob.perform_async({
        'iam_tenant_id' => args['iam_tenant_id'],
        'organisation_id' => args['id'] })

    when 'Accountify::Invoice::IssuedEvent'
      Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
        'iam_tenant_id' => args['iam_tenant_id'],
        'organisation_id' => args['organisation_id'],
        'invoice_updated_at' => args['occurred_at'] })

    when 'Accountify::Invoice::UpdatedEvent'
      Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
        'iam_tenant_id' => args['iam_tenant_id'],
        'organisation_id' => args['organisation_id'],
        'invoice_updated_at' => args['occurred_at'] })

    when 'Accountify::Invoice::PaidEvent'
      Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
        'iam_tenant_id' => args['iam_tenant_id'],
        'organisation_id' => args['organisation_id'],
        'invoice_updated_at' => args['occurred_at'] })

    when 'Accountify::Invoice::VoidedEvent'
      Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
        'iam_tenant_id' => args['iam_tenant_id'],
        'organisation_id' => args['organisation_id'],
        'invoice_updated_at' => args['occurred_at'] })

    when 'Accountify::Invoice::DeletedEvent'
      Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
        'iam_tenant_id' => args['iam_tenant_id'],
        'organisation_id' => args['organisation_id'],
        'invoice_updated_at' => args['occurred_at'] })
    end
  end
end
