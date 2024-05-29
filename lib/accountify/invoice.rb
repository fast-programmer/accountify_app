module Accountify
  module Invoice
    extend self

    module Status
      DRAFT = 'draft'
      AUTHORISED = 'authorised'
    end

    class CreatedEvent < ::Models::Event; end

    def create(iam_user:, iam_tenant:,
               organisation_id:, contact_id:,
               currency_code:, due_date:, sub_total:)
      invoice = nil
      event = nil

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice.create!(
          iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation_id,
          contact_id: contact_id,
          status: Status::DRAFT,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total[:amount],
          sub_total_currency_code: sub_total[:currency_code])

        event = CreatedEvent.create!(
          iam_user_id: iam_user[:id],
          iam_tenant_id: iam_tenant[:id],
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'status' => invoice.status,
              'currency_code' => invoice.currency_code,
              'due_date' => invoice.due_date,
              'sub_total' => {
                'amount' => invoice.sub_total_amount.to_s,
                'currency_code' => invoice.sub_total_currency_code } } })
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user[:id],
        'iam_tenant_id' => iam_tenant[:id],
        'id' => event.id,
        'type' => event.type })

      [invoice.id, event.id]
    end

    def find_by_id(iam_user:, iam_tenant:, id:)
      invoice = Models::Invoice
        .where(iam_tenant_id: iam_tenant[:id])
        .find_by!(id: id)

      {
        id: invoice.id,
        organisation_id: invoice.organisation_id,
        contact_id: invoice.contact_id,
        status: invoice.status,
        currency_code: invoice.currency_code,
        due_date: invoice.due_date,
        sub_total: {
          amount: invoice.sub_total_amount,
          currency_code: invoice.sub_total_currency }
      }
    end

    class UpdatedEvent < ::Models::Event; end

    def update(iam_user:, iam_tenant:, id:, status:, currency_code:, due_date:, sub_total_amount:)
      event = nil

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id]).lock.find_by!(id: id)

        invoice.update!(
          status: status,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total_amount )

        event = UpdatedEvent.create!(
          iam_user_id: iam_user[:id],
          iam_tenant_id: iam_tenant[:id],
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'status' => invoice.status,
              'currency_code' => invoice.currency_code,
              'due_date' => invoice.due_date,
              'sub_total_amount' => invoice.sub_total_amount
            }
          }
        )
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
        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id]).lock.find_by!(id: id)

        invoice.update!(deleted_at: DateTime.now.utc)

        event = DeletedEvent.create!(
          iam_user_id: iam_user[:id],
          iam_tenant_id: iam_tenant[:id],
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'deleted_at' => invoice.deleted_at } } )
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
