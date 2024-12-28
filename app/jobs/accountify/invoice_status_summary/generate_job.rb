module Accountify
  module InvoiceStatusSummary
    class GenerateJob
      include Sidekiq::Job

      sidekiq_options queue: 'reporting', backtrace: true

      def perform(args)
        InvoiceStatusSummary.generate(event_id: args['event_id'])
      end
    end
  end
end
