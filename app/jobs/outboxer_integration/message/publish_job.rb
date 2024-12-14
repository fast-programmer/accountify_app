module OutboxerIntegration
  module Message
    class PublishJob
      include Sidekiq::Job

      sidekiq_options queue: 'events', retry: false, backtrace: true

      def perform(args)
        case args['messageable_type']
        when 'Accountify::Organisation::CreatedEvent'
          Accountify::InvoiceStatusSummary::GenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'] })

        when 'Accountify::Invoice::DraftedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'],
            'invoice_updated_at' => args['occurred_at'] })

        when 'Accountify::Invoice::UpdatedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'],
            'invoice_updated_at' => args['occurred_at'] })

        when 'Accountify::Invoice::IssuedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'],
            'invoice_updated_at' => args['occurred_at'] })

        when 'Accountify::Invoice::PaidEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'],
            'invoice_updated_at' => args['occurred_at'] })

        when 'Accountify::Invoice::VoidedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'],
            'invoice_updated_at' => args['occurred_at'] })

        when 'Accountify::Invoice::DeletedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => args['tenant_id'],
            'organisation_id' => args['organisation_id'],
            'invoice_updated_at' => args['occurred_at'] })
        end
      end
    end
  end
end
