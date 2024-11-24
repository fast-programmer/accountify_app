module Accountify
  module Contact
    extend self

    class CreatedEvent < Event; end

    def create(user_id:, tenant_id:,
              organisation_id:, first_name:, last_name:, email:)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .create!(
            tenant_id: tenant_id,
            organisation_id: organisation_id,
            first_name: first_name,
            last_name: last_name,
            email: email)

        event = CreatedEvent
          .create!(
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'first_name' => contact.first_name,
                'last_name' => contact.last_name,
                'email' => contact.email } })
      end

      EventCreatedJob.perform_async({
        'user_id' => user_id,
        'tenant_id' => tenant_id,
        'id' => event.id,
        'type' => event.type,
        'organisation_id' => event.body['contact']['organisation_id'] })

      [contact.id, event.id]
    end

    def find_by_id(user_id:, tenant_id:, id:)
      contact = Models::Contact.where(tenant_id: tenant_id).find_by!(id: id)

      {
        id: contact.id,
        first_name: contact.first_name,
        last_name: contact.last_name,
        email: contact.email
      }
    end

    class UpdatedEvent < Event; end

    def update(user_id:, tenant_id:, id:,
               first_name:, last_name:, email:)
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        contact.update!(
          first_name: first_name,
          last_name: last_name,
          email: email)

        event = UpdatedEvent
          .create!(
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'first_name' => contact.first_name,
                'last_name' => contact.last_name,
                'email' => contact.email } })
      end

      EventCreatedJob.perform_async({
        'user_id' => user_id,
        'tenant_id' => tenant_id,
        'id' => event.id,
        'type' => event.type })

      event.id
    end

    class DeletedEvent < Event; end

    def delete(user_id:, tenant_id:, id:)
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        contact.update!(deleted_at: DateTime.now.utc)

        event = DeletedEvent
          .create!(
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'deleted_at' => contact.deleted_at } })
      end

      EventCreatedJob.perform_async({
        'user_id' => user_id,
        'tenant_id' => tenant_id,
        'id' => event.id,
        'type' => event.type })

      event.id
    end
  end
end
