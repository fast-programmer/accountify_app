module Accountify
  module InvoiceStatusSummary
    class GenerateJob
      include Sidekiq::Job

      sidekiq_options queue: 'reporting', backtrace: true

      def perform(args)
        InvoiceStatusSummary.generate(
          tenant_id: args['tenant_id'], organisation_id: args['organisation_id'])
      end
    end
  end
end
