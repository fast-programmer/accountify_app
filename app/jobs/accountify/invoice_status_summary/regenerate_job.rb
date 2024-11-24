module Accountify
  module InvoiceStatusSummary
    class RegenerateJob
      include Sidekiq::Job

      sidekiq_options queue: 'reporting', backtrace: true

      def perform(args)
        InvoiceStatusSummary.regenerate(
          iam_tenant_id: args['iam_tenant_id'],
          organisation_id: args['organisation_id'],
          invoice_updated_at: args['invoice_updated_at'],
          current_time: Time.current)
      rescue NotAvailable
        RegenerateJob.perform_in(1.minute, args)
      end
    end
  end
end
