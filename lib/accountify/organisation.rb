module Accountify
  module Organisation
    extend self

    class CreatedEvent < Models::Event; end

    def create(user:, tenant:, id:, name:)
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
            payload: {
              'id' => id,
              'name' => name,
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } } )
      end

      job_id = Event::CreatedJob.perform_async({
        'user_id' => user[:id],
        'tenant_id' => tenant[:id],
        'id' => event.id,
        'type' => event.type })

      { id: id, event_id: event.id, job_id: job_id }
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

    class UpdatedEvent < Models::Event; end

    def update(user:, tenant:, id:, name:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant.id)
          .lock
          .find_by!(id: id)

        organisation.update!(name: name)

        event = UpdatedEvent
          .where(user_id: user[:id], tenant_id: tenant[:id])
          .create!(
            eventable: organisation,
            payload: {
              'id' => id,
              'name' => name,
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } })
      end

      job_id = Event::CreatedJob.perform_async({
        'user_id' => user[:id],
        'tenant_id' => tenant[:id],
        'id' => event.id,
        'type' => event.type })

      { id: id, event_id: event.id, job_id: job_id }
    end

    def delete(user:, tenant:, id:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant.id)
          .lock
          .find_by!(id: id)

        organisation.update!(is_deleted: true)

        event = DeletedEvent
          .where(user_id: user[:id], tenant_id: tenant[:id])
          .create!(
            eventable: organisation,
            payload: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name,
                'is_deleted' => organisation.is_deleted } })
      end

      job_id = Event::CreatedJob.perform_async({
        'user_id' => user[:id],
        'tenant_id' => tenant[:id],
        'id' => event.id,
        'type' => event.type })

      { id: id, event_id: event.id, job_id: job_id }
    end
  end
end
