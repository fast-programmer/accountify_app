module Event
  class CreatedJob
    include Sidekiq::Job

    sidekiq_options retry: false, backtrace: true

    def perform(args)
      event = Models::Event
        .where(iam_tenant_id: args['iam_tenant_id'])
        .find(args['id'])

      logger.info "event #{event.id} processed"
    end
  end
end
