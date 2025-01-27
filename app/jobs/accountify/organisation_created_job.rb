module Accountify
  class OrganisationCreatedJob
    include Sidekiq::Job

    sidekiq_options retry: false, backtrace: true

    def perform(args)
      GenerateInvoiceStatusSummaryJob.perform_async({ 'event_id' => args['event_id'] })
    end
  end
end
