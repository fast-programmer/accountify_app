module Accountify
  module Organisation
    extend self

    class CreatedEvent < ::Models::Event; end

    def create(user:, tenant:, name:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant[:id])
          .create!(name: name)

        event = CreatedEvent
          .where(user_id: user[:id], tenant_id: tenant[:id])
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } } )
      end

      Event::CreatedJob.perform_async({
        'user_id' => user[:id],
        'tenant_id' => tenant[:id],
        'id' => event.id,
        'type' => event.type })

      { id: organisation.id, event_id: event.id }
    end

    def find_by_id(user:, tenant:, id:)
      organisation = Models::Organisation
        .where(tenant_id: tenant[:id])
        .find_by!(id: id)

      {
        id: organisation.id,
        name: organisation.name
      }
    end

    class UpdatedEvent < ::Models::Event; end

    def update(user:, tenant:, id:, name:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant[:id])
          .lock
          .find_by!(id: id)

        organisation.update!(name: name)

        event = UpdatedEvent
          .where(user_id: user[:id], tenant_id: tenant[:id])
          .create!(
            eventable: organisation,
            body: {
              'id' => id,
              'name' => name,
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } })
      end

      Event::CreatedJob.perform_async({
        'user_id' => user[:id],
        'tenant_id' => tenant[:id],
        'id' => event.id,
        'type' => event.type })

      { id: organisation.id, event_id: event.id }
    end

    class DeletedEvent < ::Models::Event; end

    def delete(user:, tenant:, id:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant[:id])
          .lock
          .find_by!(id: id)

        organisation.update!(deleted_at: DateTime.now.utc)

        event = DeletedEvent
          .where(user_id: user[:id], tenant_id: tenant[:id])
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name,
                'deleted_at' => organisation.deleted_at } })
      end

      Event::CreatedJob.perform_async({
        'user_id' => user[:id],
        'tenant_id' => tenant[:id],
        'id' => event.id,
        'type' => event.type })

      { id: organisation.id, event_id: event.id }
    end
  end
end
