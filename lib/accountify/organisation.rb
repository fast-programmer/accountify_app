module Accountify
  module Organisation
    extend self

    class CreatedEvent < ::Models::Event; end

    def create(iam_user:, iam_tenant:, name:)
      organisation = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id])
          .create!(name: name)

        event = CreatedEvent
          .where(iam_user_id: iam_user[:id], iam_tenant_id: iam_tenant[:id])
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } } )
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user[:id],
        'iam_tenant_id' => iam_tenant[:id],
        'id' => event.id,
        'type' => event.type })

      [organisation.id, event.id]
    end

    def find_by_id(iam_user:, iam_tenant:, id:)
      organisation = Models::Organisation
        .where(iam_tenant_id: iam_tenant[:id])
        .find_by!(id: id)

      {
        id: organisation.id,
        name: organisation.name
      }
    end

    class UpdatedEvent < ::Models::Event; end

    def update(iam_user:, iam_tenant:, id:, name:)
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id]).lock.find_by!(id: id)

        organisation.update!(name: name)

        event = UpdatedEvent
          .where(iam_user_id: iam_user[:id], iam_tenant_id: iam_tenant[:id])
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name } })
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
        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant[:id]).lock.find_by!(id: id)

        organisation.update!(deleted_at: DateTime.now.utc)

        event = DeletedEvent
          .where(iam_user_id: iam_user[:id], iam_tenant_id: iam_tenant[:id])
          .create!(
            eventable: organisation,
            body: {
              'organisation' => {
                'id' => organisation.id,
                'name' => organisation.name,
                'deleted_at' => organisation.deleted_at } })
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
