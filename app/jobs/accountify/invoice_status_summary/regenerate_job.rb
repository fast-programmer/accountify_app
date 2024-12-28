module Accountify
  module InvoiceStatusSummary
    class RegenerateJob
      include Sidekiq::Job

      sidekiq_options queue: 'reporting', backtrace: true

      def perform(args)
        InvoiceStatusSummary.regenerate(event_id: args['event_id'])
      rescue NotAvailable
        RegenerateJob.perform_in(1.minute, args)
      end
    end
  end
end
