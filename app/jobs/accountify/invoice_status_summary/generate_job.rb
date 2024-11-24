module Accountify
  module InvoiceStatusSummary
    class GenerateJob
      include Sidekiq::Job

      sidekiq_options queue: 'reporting', backtrace: true

      def perform(args)
        InvoiceStatusSummary.generate(
          iam_tenant_id: args['iam_tenant_id'],
          organisation_id: args['organisation_id'],
          current_time: Time.current)
      end
    end
  end
end
