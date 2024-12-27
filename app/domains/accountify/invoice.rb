module Accountify
  module Invoice
    extend self

    module Status
      DRAFTED = 'drafted'
      ISSUED = 'issued'
      PAID = 'paid'
      VOIDED = 'voided'
    end

    def draft(user_id:, tenant_id:,
              organisation_id:, contact_id:,
              currency_code:, due_date:, line_items:,
              time: ::Time)
      invoice = nil
      event = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant_id)
          .find_by!(id: organisation_id)

        contact = Models::Contact
          .where(tenant_id: tenant_id)
          .find_by!(organisation_id: organisation.id, id: contact_id)

        invoice = Models::Invoice.create!(
          tenant_id: tenant_id,
          organisation_id: organisation_id,
          contact_id: contact_id,
          status: Status::DRAFTED,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: line_items.sum do |line_item|
            BigDecimal(line_item[:unit_amount][:amount]) * line_item[:quantity].to_i
          end,
          sub_total_currency_code: currency_code,
          created_at: current_utc_time,
          updated_at: current_utc_time)

        invoice_line_items = line_items.map do |line_item|
          invoice.line_items.create!(
            description: line_item[:description],
            unit_amount_amount: BigDecimal(line_item[:unit_amount][:amount]),
            unit_amount_currency_code: line_item[:unit_amount][:currency_code],
            quantity: line_item[:quantity])
        end

        event = Models::Invoice::DraftedEvent.create!(
          user_id: user_id,
          tenant_id: tenant_id,
          created_at: current_utc_time,
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'organisation_id' => organisation.id,
              'contact_id' => contact.id,
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

      { id: invoice.id, events: [{ id: event.id, type: event.type }] }
    end

    def find_by_id(user_id:, tenant_id:, id:)
      invoice = Models::Invoice
        .includes(:events)
        .where(tenant_id: tenant_id)
        .find_by!(id: id)

      {
        id: invoice.id,
        organisation_id: invoice.organisation_id,
        contact_id: invoice.contact_id,
        status: invoice.status,
        currency_code: invoice.currency_code,
        due_date: invoice.due_date.to_s,
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
          currency_code: invoice.sub_total_currency_code },
        events: invoice.events.map do |event|
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
               organisation_id:, contact_id:,
               due_date:, line_items:,
               time: ::Time)
      invoice = nil
      event = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.transaction do
        organisation = Models::Organisation
          .where(tenant_id: tenant_id)
          .find_by!(id: organisation_id)

        contact = Models::Contact
          .where(tenant_id: tenant_id)
          .find_by!(organisation_id: organisation.id, id: contact_id)

        invoice = Models::Invoice
          .where(tenant_id: tenant_id).lock.find_by!(id: id)

        invoice.line_items.destroy_all

        invoice.update!(
          tenant_id: tenant_id,
          organisation_id: organisation.id,
          updated_at: current_utc_time,
          contact_id: contact.id,
          status: Status::DRAFTED,
          due_date: due_date,
          sub_total_amount: line_items.sum do |line_item|
            BigDecimal(line_item[:unit_amount][:amount]) * line_item[:quantity].to_i
          end)

        invoice_line_items = line_items.map do |line_item|
          invoice.line_items.create!(
            description: line_item[:description],
            unit_amount_amount: line_item[:unit_amount][:amount],
            unit_amount_currency_code: line_item[:unit_amount][:currency_code],
            quantity: line_item[:quantity])
        end

        event = Models::Invoice::UpdatedEvent.create!(
          user_id: user_id,
          tenant_id: tenant_id,
          created_at: current_utc_time,
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

      { id: invoice.id, events: [{ id: event.id, type: event.type }] }
    end

    def delete(user_id:, tenant_id:, id:, time: ::Time)
      invoice = nil
      event = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice.where(tenant_id: tenant_id).lock.find_by!(id: id)

        invoice.update!(updated_at: current_utc_time, deleted_at: current_utc_time)

        event = Models::Invoice::DeletedEvent.create!(
          user_id: user_id,
          tenant_id: tenant_id,
          created_at: current_utc_time,
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'organisation_id' => invoice.organisation_id,
              'deleted_at' => invoice.deleted_at } } )
      end

      { id: invoice.id, events: [{ id: event.id, type: event.type }] }
    end

    def issue(user_id:, tenant_id:, id:, time: ::Time)
      invoice = nil
      event = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice.where(tenant_id: tenant_id).lock.find_by!(id: id)

        invoice.update!(
          status: Invoice::Status::ISSUED,
          issued_at: current_utc_time,
          updated_at: current_utc_time)

        event = Models::Invoice::IssuedEvent.create!(
          user_id: user_id,
          tenant_id: tenant_id,
          created_at: current_utc_time,
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'status' => invoice.status,
              'issued_at' => invoice.issued_at,
              'organisation_id' => invoice.organisation_id } })
      end

      { id: invoice.id, events: [{ id: event.id, type: event.type }] }
    end

    def paid(user_id:, tenant_id:, id:, time: ::Time)
      invoice = nil
      event = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice.where(tenant_id: tenant_id).lock.find_by!(id: id)

        if invoice.status != Invoice::Status::ISSUED
          raise "Accountify::Invoice #{id} must be issued, not #{invoice.status}"
        end

        invoice.update!(status: Invoice::Status::PAID, paid_at: Time.current)

        event = Models::Invoice::PaidEvent.create!(
          user_id: user_id,
          tenant_id: tenant_id,
          eventable: invoice,
          created_at: current_utc_time,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'status' => invoice.status,
              'paid_at' => invoice.paid_at,
              'organisation_id' => invoice.organisation_id } } )
      end

      { id: invoice.id, events: [{ id: event.id, type: event.type }] }
    end

    def void(user_id:, tenant_id:, id:, time: ::Time)
      invoice = nil
      event = nil

      ActiveRecord::Base.transaction do
        invoice = Models::Invoice.where(tenant_id: tenant_id).lock.find_by!(id: id)

        invoice.update!(status: Invoice::Status::VOIDED)

        event = Models::Invoice::VoidedEvent.create!(
          user_id: user_id,
          tenant_id: tenant_id,
          eventable: invoice,
          body: {
            'invoice' => {
              'id' => invoice.id,
              'status' => invoice.status,
              'organisation_id' => invoice.organisation_id } } )
      end

      { id: invoice.id, events: [{ id: event.id, type: event.type }] }
    end
  end
end
