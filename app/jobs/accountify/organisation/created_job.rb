module Accountify
  module Organisation
    class CreatedJob
      include Sidekiq::Job

      sidekiq_options retry: false, backtrace: true

      def perform(args)
        InvoiceStatusSummary::GenerateJob.perform_async({ 'event_id' => args['event_id'] })
      end
    end
  end
end
