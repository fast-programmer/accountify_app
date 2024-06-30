module Accountify
  module AgedReceivablesReport
    class GenerateJob
      include Sidekiq::Job

      def perform(args)
        AgedReceivablesReport.generate({
          'iam_tenant_id' => args['iam_tenant_id'] })
      end
    end
  end
end
