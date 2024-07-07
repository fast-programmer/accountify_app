module Accountify
  module InvoiceStatusSummary
    class RegenerateJob
      include Sidekiq::Job

      def perform(args)
        InvoiceStatusSummary.regenerate(
          iam_tenant_id: args['iam_tenant_id'],
          organisation_id: args['organisation_id'],
          generate_at_timestamp: args['generate_at_timestamp'] || Time.current,
          current_time: Time.current)
      rescue NotAvailable
        RegenerateJob.perform_in(1.minute, args)
      end
    end
  end
end
