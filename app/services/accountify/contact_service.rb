module Accountify
  module ContactService
    extend self

    def create(user_id:, tenant_id:,
              organisation_id:, first_name:, last_name:, email:)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Contact
          .create!(
            tenant_id: tenant_id,
            organisation_id: organisation_id,
            first_name: first_name,
            last_name: last_name,
            email: email)

        event = ContactCreatedEvent
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

      { id: contact.id, events: [{ id: event.id, type: event.type }] }
    end

    def find_by_id(user_id:, tenant_id:, id:)
      contact = Contact
        .includes(:events)
        .where(tenant_id: tenant_id)
        .find_by!(id: id)

      {
        id: contact.id,
        first_name: contact.first_name,
        last_name: contact.last_name,
        email: contact.email,
        events: contact.events.map do |event|
          {
            id: event.id,
            type: event.type,
            eventable_type: event.eventable_type,
            eventable_id: event.eventable_id,
            body: event.body,
            created_at: event.created_at
          }
        end
      }
    end

    def update(user_id:, tenant_id:, id:,
               first_name:, last_name:, email:)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Contact
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        contact.update!(
          first_name: first_name,
          last_name: last_name,
          email: email)

        event = ContactUpdatedEvent
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

      { id: contact.id, events: [{ id: event.id, type: event.type }] }
    end

    def delete(user_id:, tenant_id:, id:, time: ::Time)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Contact
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        contact.update!(deleted_at: time.now.utc)

        event = ContactDeletedEvent
          .create!(
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: contact,
            body: {
              'contact' => {
                'id' => contact.id,
                'deleted_at' => contact.deleted_at } })
      end

      { id: contact.id, events: [{ id: event.id, type: event.type }] }
    end
  end
end
