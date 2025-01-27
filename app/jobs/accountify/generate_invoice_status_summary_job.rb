module Accountify
  class GenerateInvoiceStatusSummaryJob
    include Sidekiq::Job

    sidekiq_options queue: 'reporting', backtrace: true

    def perform(args)
      InvoiceStatusSummaryService.generate(event_id: args['event_id'])
    end
  end
end
