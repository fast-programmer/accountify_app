module Accountify
  module Contact
    extend self

    class CreatedEvent < ::Models::Event; end

    def create(iam_user:, iam_tenant:, organisation_id:, first_name:, last_name:, email:)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .create!(
            iam_tenant_id: iam_tenant[:id],
            organisation_id: organisation_id,
            first_name: first_name,
            last_name: last_name,
            email: email)

        event = CreatedEvent
          .create!(
            iam_user_id: iam_user[:id],
            iam_tenant_id: iam_tenant[:id],
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'first_name' => contact.first_name,
                'last_name' => contact.last_name,
                'email' => contact.email } })
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user[:id],
        'iam_tenant_id' => iam_tenant[:id],
        'id' => event.id,
        'type' => event.type })

      [contact.id, event.id]
    end

    def find_by_id(iam_user:, iam_tenant:, id:)
      contact = Models::Contact
        .where(iam_tenant_id: iam_tenant[:id])
        .find_by!(id: id)

      {
        id: contact.id,
        first_name: contact.first_name,
        last_name: contact.last_name,
        email: contact.email
      }
    end

    class UpdatedEvent < ::Models::Event; end

    def update(iam_user:, iam_tenant:, id:, first_name:, last_name:, email:)
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id]).lock.find_by!(id: id)

        contact.update!(
          first_name: first_name,
          last_name: last_name,
          email: email)

        event = UpdatedEvent
          .create!(
            iam_user_id: iam_user[:id],
            iam_tenant_id: iam_tenant[:id],
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'first_name' => contact.first_name,
                'last_name' => contact.last_name,
                'email' => contact.email } })
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user[:id],
        'iam_tenant_id' => iam_tenant[:id],
        'id' => event.id,
        'type' => event.type })

      event.id
    end

    class DeletedEvent < ::Models::Event; end

    def delete(iam_user:, iam_tenant:, id:)
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant[:id]).lock.find_by!(id: id)

        contact.update!(deleted_at: DateTime.now.utc)

        event = DeletedEvent
          .create!(
            iam_user_id: iam_user[:id],
            iam_tenant_id: iam_tenant[:id],
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'deleted_at' => contact.deleted_at } })
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user[:id],
        'iam_tenant_id' => iam_tenant[:id],
        'id' => event.id,
        'type' => event.type })

      event.id
    end
  end
end
