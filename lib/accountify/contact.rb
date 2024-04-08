module Accountify
  module Contact
    extend self

    def update(iam_user:, iam_account:, id:, first_name:)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact.where(iam_account_id: iam_account.id).lock.find_by!(id: id)

        contact.update!(first_name: first_name)

        event = UpdatedEvent.create!(
          iam_user_id: iam_user_id,
          iam_account_id: iam_account.id,
          eventable: contact,
          payload: {
            'first_name' => first_name,
            'contact' => {
              'id' => contact.id,
              'first_name' => first_name } })
      end

      job_id = Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user.id,
        'iam_account_id' => iam_account.id,
        'id' => event.id,
        'type' => event.type })

      { id: id, event_id: event.id, job_id: job_id }
    end
  end
end
