class EventHandlerJob
  include Sidekiq::Job

  def perform(args)
    event = Event.find(args['id'])

    logger.info "[#{event.id}] processed"
  end
end
