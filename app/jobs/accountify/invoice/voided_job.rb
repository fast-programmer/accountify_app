module Accountify
  module Invoice
    class VoidedJob
      include Sidekiq::Job

      sidekiq_options queue: 'event_handlers', backtrace: true

      def perform(args)
        InvoiceStatusSummary.generate(
          tenant_id: args['tenant_id'], organisation_id: args['organisation_id'])
      end
    end
  end
end
