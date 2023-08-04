class HardJob
  include Sidekiq::Job

  def perform(args)
    message = Message.find(args['message_id'])

    logger.info "[#{message.id}] processed"
  end
end
