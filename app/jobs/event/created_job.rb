module Event
  class CreatedJob
    include Sidekiq::Job

    sidekiq_options queue: 'events', retry: false

    def perform(args)
      case args['type']
      when 'Accountify::Invoice::IssuedEvent'
        Accountify::AgedReceivablesReport::GenerateJob.perform_async({
          'iam_tenant_id' => args['iam_tenant_id'] })
      when 'Accountify::Invoice::UpdatedEvent'
        Accountify::AgedReceivablesReport::GenerateJob.perform_async({
          'iam_tenant_id' => args['iam_tenant_id'] })
      when 'Accountify::Invoice::PaidEvent'
        Accountify::AgedReceivablesReport::GenerateJob.perform_async({
          'iam_tenant_id' => args['iam_tenant_id'] })
      when 'Accountify::Invoice::VoidedEvent'
        Accountify::AgedReceivablesReport::GenerateJob.perform_async({
          'iam_tenant_id' => args['iam_tenant_id'] })
      when 'Accountify::Invoice::DeletedEvent'
        Accountify::AgedReceivablesReport::GenerateJob.perform_async({
          'iam_tenant_id' => args['iam_tenant_id'] })
      end
    end
  end
end

