module Accountify
  module Invoice
    class VoidedJob
      include Sidekiq::Job

      sidekiq_options retry: false, backtrace: true

      def perform(args)
        event = ActiveRecord::Base.connection_pool.with_connection do
          Models::Invoice::VoidedEvent.find(args['id'])
        end

        InvoiceStatusSummary::RegenerateJob.perform_async({
          'tenant_id' => event.tenant_id,
          'organisation_id' => event.body['organisation']['id'],
          'invoice_updated_at' => event.created_at.utc.iso8601 })
      end
    end
  end
end
