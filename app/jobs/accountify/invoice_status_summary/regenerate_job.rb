module Accountify
  module InvoiceStatusSummary
    class RegenerateJob
      include Sidekiq::Job

      sidekiq_options queue: 'reporting', backtrace: true

      def perform(args)
        InvoiceStatusSummary.regenerate(
          tenant_id: args['tenant_id'],
          organisation_id: args['organisation_id'],
          invoice_updated_at: args['invoice_updated_at'])
      rescue NotAvailable
        RegenerateJob.perform_in(1.minute, args)
      end
    end
  end
end
