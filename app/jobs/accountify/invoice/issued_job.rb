module Accountify
  module Invoice
    class IssuedJob
      include Sidekiq::Job

      sidekiq_options queue: 'events', retry: false, backtrace: true

      def perform(args)
      end
    end
  end
end
