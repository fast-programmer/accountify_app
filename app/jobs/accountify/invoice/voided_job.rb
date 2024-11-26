module Accountify
  module Invoice
    class VoidedJob
      include Sidekiq::Job

      sidekiq_options queue: 'events', retry: false, backtrace: true

      def perform(args)
      end
    end
  end
end
