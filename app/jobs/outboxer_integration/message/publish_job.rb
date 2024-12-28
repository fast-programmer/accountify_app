module OutboxerIntegration
  module Message
    class PublishJob
      include Sidekiq::Job

      sidekiq_options retry: false, backtrace: true

      MESSAGEABLE_TYPE_REGEX = /\A([A-Za-z]+)::Models::([A-Za-z]+)::([A-Za-z]+)Event\z/

      def perform(args)
        messageable_type = args['messageable_type']

        if !messageable_type.match(MESSAGEABLE_TYPE_REGEX)
          raise StandardError, "Unexpected class name format: #{messageable_type}"
        end

        namespace, model, event = messageable_type.match(MESSAGEABLE_TYPE_REGEX).captures
        job_class_name = "#{namespace}::#{model}::#{event}Job"

        begin
          job_class = job_class_name.constantize
          job_class.perform_async({ 'id' => args['messageable_id'] })
        rescue NameError
          # no-op
        end
      end
    end
  end
end
