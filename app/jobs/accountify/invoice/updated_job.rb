module Accountify
  module Invoice
    class UpdatedJob
      include Sidekiq::Job

      sidekiq_options retry: false, backtrace: true

      def perform(args)
        InvoiceStatusSummary::RegenerateJob.perform_async({ 'event_id' => args['event_id'] })
      end
    end
  end
end
