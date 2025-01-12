module Accountify
  class InvoiceVoidedJob
    include Sidekiq::Job

    sidekiq_options retry: false, backtrace: true

    def perform(args)
      RegenerateInvoiceStatusSummaryJob.perform_async({ 'event_id' => args['event_id'] })
    end
  end
end
