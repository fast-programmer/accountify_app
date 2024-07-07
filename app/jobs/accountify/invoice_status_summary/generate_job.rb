module Accountify
  module InvoiceStatusSummary
    class GenerateJob
      include Sidekiq::Job

      def perform(args)
        InvoiceStatusSummary.regenerate(
          iam_tenant_id: args['iam_tenant_id'],
          organisation_id: args['organisation_id'],
          current_time: Time.current)
      end
    end
  end
end
