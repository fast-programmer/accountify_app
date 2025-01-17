module Accountify
  module InvoiceStatusSummaryService
    extend self

    def generate(event_id:, time: ::Time)
      tenant_id = nil
      organisation_id = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction(isolation: :repeatable_read) do
          event = Event.find(event_id)

          tenant_id = event.tenant_id
          organisation_id = event.body['organisation']['id']

          grouped_invoices = Invoice
            .where(tenant_id: tenant_id, organisation_id: organisation_id).group(:status)
            .count

          InvoiceStatusSummary.create!(
            tenant_id: tenant_id,
            organisation_id: organisation_id,
            generated_at: current_utc_time,
            drafted_count: grouped_invoices[Invoice::Status::DRAFTED] || 0,
            issued_count: grouped_invoices[Invoice::Status::ISSUED] || 0,
            paid_count: grouped_invoices[Invoice::Status::PAID] || 0,
            voided_count: grouped_invoices[Invoice::Status::VOIDED] || 0)
        end
      end

      find_by_organisation_id(tenant_id: tenant_id, organisation_id: organisation_id)
    end

    def regenerate(event_id:, invoice_updated_at: ::Time.now.utc, time: ::Time)
      tenant_id = nil
      organisation_id = nil

      current_utc_time = time.now.utc

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction(isolation: :repeatable_read) do
          event = Event.find(event_id)

          tenant_id = event.tenant_id
          organisation_id = event.body['organisation']['id']

          summary = InvoiceStatusSummary
            .where('generated_at <= ?', invoice_updated_at)
            .lock('FOR UPDATE NOWAIT')
            .find_by!(tenant_id: tenant_id, organisation_id: organisation_id)

          grouped_invoices = Invoice
            .where(tenant_id: tenant_id, organisation_id: organisation_id).group(:status)
            .count

          summary.update!(
            generated_at: current_utc_time,
            drafted_count: grouped_invoices[Invoice::Status::DRAFTED] || 0,
            issued_count: grouped_invoices[Invoice::Status::ISSUED] || 0,
            paid_count: grouped_invoices[Invoice::Status::PAID] || 0,
            voided_count: grouped_invoices[Invoice::Status::VOIDED] || 0)
        end
      end

      find_by_organisation_id(tenant_id: tenant_id, organisation_id: organisation_id)
    rescue ActiveRecord::RecordNotFound
      find_by_organisation_id(tenant_id: tenant_id, organisation_id: organisation_id)
    rescue ActiveRecord::LockWaitTimeout => error
      raise Accountify::NotAvailable.new,
        "Resource temporarily unavailable. Original error: #{error.message}"
    end

    def find_by_organisation_id(tenant_id:, organisation_id:)
      ActiveRecord::Base.connection_pool.with_connection do
        summary = InvoiceStatusSummary
          .find_by!(tenant_id: tenant_id, organisation_id: organisation_id)

        {
          id: summary.id,
          generated_at: summary.generated_at,
          drafted_count: summary.drafted_count,
          issued_count: summary.issued_count,
          paid_count: summary.paid_count,
          voided_count: summary.voided_count,
          created_at: summary.created_at,
          updated_at: summary.updated_at
        }
      end
    rescue ActiveRecord::RecordNotFound
      raise NotFound.new, "InvoiceStatusSummary organisation_id=#{organisation_id} not found"
    end
  end
end
