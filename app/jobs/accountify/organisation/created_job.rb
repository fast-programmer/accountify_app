module Accountify
  module Organisation
    class CreatedJob
      include Sidekiq::Job

      sidekiq_options retry: false, backtrace: true

      def perform(args)
        event = ActiveRecord::Base.connection_pool.with_connection do
          Models::Organisation::CreatedEvent.find(args['id'])
        end

        InvoiceStatusSummary::GenerateJob.perform_async({
          'tenant_id' => event.tenant_id,
          'organisation_id' => event.body['organisation']['id'] })
      end
    end
  end
end
