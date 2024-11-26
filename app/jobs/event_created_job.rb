class EventCreatedJob
  include Sidekiq::Job

  sidekiq_options queue: 'events', retry: false, backtrace: true

  def perform(args)
    case args['type']
    when 'Accountify::Organisation::CreatedEvent'
      Accountify::Organisation::CreatedJob.perform_async(args)
    when 'Accountify::Invoice::IssuedEvent'
      Accountify::Invoice::IssuedJob.perform_async(args)
    when 'Accountify::Invoice::UpdatedJob'
      Accountify::Invoice::UpdatedJob.perform_async(args)
    when 'Accountify::Invoice::PaidEvent'
      Accountify::Invoice::PaidJob.perform_async(args)
    when 'Accountify::Invoice::VoidedEvent'
      Accountify::Invoice::VoidedJob.perform_async(args)
    when 'Accountify::Invoice::DeletedEvent'
      Accountify::Invoice::DeletedJob.perform_async(args)
    end
  end
end
