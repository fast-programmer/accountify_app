module Accountify
  module Invoice
    extend self

    module Status
      DRAFT = 'draft'
      AUTHORISED = 'authorised'
    end

    class CreatedEvent < ::Models::Event; end

    def create(iam_user_id:, iam_tenant_id:,
               organisation_id:, contact_id:,
               currency_code:, due_date:, line_items:)
      invoice = nil
      event = nil

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice.create!(
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          contact_id: contact_id,
          status: Status::DRAFT,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: line_items.sum do |line_item|
            line_item[:unit_amount][:amount] * line_item[:quantity]
          end,
          sub_total_currency_code: currency_code)

        invoice_line_items = line_items.map do |line_item|
          invoice.line_items.create!(
            description: line_item[:description],
            unit_amount_amount: line_item[:unit_amount][:amount],
            unit_amount_currency_code: line_item[:unit_amount][:currency_code],
            quantity: line_item[:quantity])
        end

        event = CreatedEvent.create!(
          iam_user_id: iam_user_id,
          iam_tenant_id: iam_tenant_id,
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'status' => invoice.status,
              'currency_code' => invoice.currency_code,
              'due_date' => invoice.due_date,
              'line_items' => invoice_line_items.map do |invoice_line_item|
                {
                  'description' => invoice_line_item.description,
                  'unit_amount_amount' => invoice_line_item.unit_amount_amount.to_s,
                  'unit_amount_currency_code' => invoice_line_item.unit_amount_currency_code,
                  'quantity' => invoice_line_item.quantity
                }
              end,
              'sub_total' => {
                'amount' => invoice.sub_total_amount.to_s,
                'currency_code' => invoice.sub_total_currency_code } } })
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user_id,
        'iam_tenant_id' => iam_tenant_id,
        'id' => event.id,
        'type' => event.type })

      [invoice.id, event.id]
    end

    def find_by_id(iam_user:, iam_tenant:, id:)
      invoice = Models::Invoice.where(iam_tenant_id: iam_tenant[:id]).find_by!(id: id)

      {
        id: invoice.id,
        organisation_id: invoice.organisation_id,
        contact_id: invoice.contact_id,
        status: invoice.status,
        currency_code: invoice.currency_code,
        due_date: invoice.due_date,
        line_items: invoice.line_items.map do |line_item|
          {
            description: line_item[:description],
            unit_amount: {
              amount: line_item.unit_amount_amount,
              currency_code: line_item.unit_amount_currency_code },
            quantity: line_item.quantity
          }
        end,
        sub_total: {
          amount: invoice.sub_total_amount,
          currency_code: invoice.sub_total_currency_code }
      }
    end

    class UpdatedEvent < ::Models::Event; end

    def update(iam_user_id:, iam_tenant_id:, id:,
               organisation_id:, contact_id:,
               due_date:, line_items:)
      invoice = nil
      event = nil

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(iam_tenant_id: iam_tenant_id).lock.find_by!(id: organisation_id)

        contact = Models::Contact
          .where(iam_tenant_id: iam_tenant_id)
          .lock.find_by!(organisation_id: organisation.id, id: contact_id)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant_id).lock.find_by!(id: id)

        invoice.update!(
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: Status::DRAFT,
          due_date: due_date,
          sub_total_amount: line_items.sum do |line_item|
            line_item[:unit_amount][:amount] * line_item[:quantity]
          end)

        invoice.line_items.delete_all

        invoice_line_items = line_items.map do |line_item|
          invoice.line_items.create!(
            description: line_item[:description],
            unit_amount_amount: line_item[:unit_amount][:amount],
            unit_amount_currency_code: line_item[:unit_amount][:currency_code],
            quantity: line_item[:quantity])
        end

        event = UpdatedEvent.create!(
          iam_user_id: iam_user_id,
          iam_tenant_id: iam_tenant_id,
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'organisation_id' => organisation.id,
              'contact_id' => contact.id,
              'status' => invoice.status,
              'currency_code' => invoice.currency_code,
              'due_date' => invoice.due_date.to_s,
              'line_items' => invoice_line_items.map do |invoice_line_item|
                {
                  'description' => invoice_line_item.description,
                  'unit_amount_amount' => invoice_line_item.unit_amount_amount.to_s,
                  'unit_amount_currency_code' => invoice_line_item.unit_amount_currency_code,
                  'quantity' => invoice_line_item.quantity
                }
              end,
              'sub_total' => {
                'amount' => invoice.sub_total_amount.to_s,
                'currency_code' => invoice.sub_total_currency_code } } })
      end

      Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user_id,
        'iam_tenant_id' => iam_tenant_id,
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
