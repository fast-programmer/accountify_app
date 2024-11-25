module Accountify
  module Organisation
    extend self

    class CreatedEvent < Event; end

    def create(user_id:, tenant_id:, name:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant_id)
          .create!(name: name)

        event = CreatedEvent
          .where(user_id: user_id, tenant_id: tenant_id)
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } } )
      end

      EventCreatedJob.perform_async({
        'user_id' => user_id,
        'tenant_id' => tenant_id,
        'id' => event.id,
        'type' => event.type,
        'organisation_id' => event['body']['organisation']['id'] })

      { id: organisation.id, events: [{ id: event.id, type: event.type }] }
    end

    def find_by_id(user_id:, tenant_id:, id:)
      organisation = Models::Organisation
        .includes(:events)
        .where(tenant_id: tenant_id)
        .find_by!(id: id)

      {
        id: organisation.id,
        name: organisation.name,
        events: organisation.events.map do |event|
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

    class UpdatedEvent < Event; end

    def update(user_id:, tenant_id:, id:, name:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        organisation.update!(name: name)

        event = UpdatedEvent
          .where(user_id: user_id, tenant_id: tenant_id)
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } })
      end

      EventCreatedJob.perform_async({
        'user_id' => user_id,
        'tenant_id' => tenant_id,
        'id' => event.id,
        'type' => event.type })

      { id: organisation.id, events: [{ id: event.id, type: event.type }] }
    end

    class DeletedEvent < Event; end

    def delete(user_id:, tenant_id:, id:, time: ::Time)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        organisation.update!(deleted_at: time.now.utc)

        event = DeletedEvent
          .where(user_id: user_id, tenant_id: tenant_id)
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name,
                'deleted_at' => organisation.deleted_at } })
      end

      EventCreatedJob.perform_async({
        'user_id' => user_id,
        'tenant_id' => tenant_id,
        'id' => event.id,
        'type' => event.type })

      { id: organisation.id, events: [{ id: event.id, type: event.type }] }
    end
  end
end
