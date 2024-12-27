module OutboxerIntegration
  module Message
    class PublishJob
      include Sidekiq::Job

      sidekiq_options queue: 'events', retry: false, backtrace: true

      def perform(args)
        messageable = ActiveRecord::Base.connection_pool.with_connection do
          args['messageable_type'].constantize.find(args['messageable_id'])
        end

        case args['messageable_type']
        when 'Accountify::Models::Organisation::CreatedEvent'
          Accountify::InvoiceStatusSummary::GenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'] })

        when 'Accountify::Models::Invoice::DraftedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'],
            'invoice_updated_at' => messageable.created_at.utc.iso8601 })

        when 'Accountify::Models::Invoice::UpdatedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'],
            'invoice_updated_at' => messageable.created_at.utc.iso8601 })

        when 'Accountify::Models::Invoice::IssuedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'],
            'invoice_updated_at' => messageable.created_at.utc.iso8601 })

        when 'Accountify::Models::Invoice::PaidEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'],
            'invoice_updated_at' => messageable.created_at.utc.iso8601 })

        when 'Accountify::Models::Invoice::VoidedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'],
            'invoice_updated_at' => messageable.created_at.utc.iso8601 })

        when 'Accountify::Models::Invoice::DeletedEvent'
          Accountify::InvoiceStatusSummary::RegenerateJob.perform_async({
            'tenant_id' => messageable.tenant_id,
            'organisation_id' => messageable.body['organisation']['id'],
            'invoice_updated_at' => messageable.created_at.utc.iso8601 })
        end
      end
    end
  end
end
