module Accountify
  module InvoiceStatusSummary
    extend self

    def generate(iam_tenant_id:, organisation_id:, current_time: Time.current)
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction(isolation: :repeatable_read) do
          grouped_invoices = Models::Invoice
            .where(iam_tenant_id: iam_tenant_id, organisation_id: organisation_id).group(:status)
            .count

          Models::InvoiceStatusSummary.create!(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            generated_at: current_time.utc,
            draft_count: grouped_invoices[Invoice::Status::DRAFT] || 0,
            issued_count: grouped_invoices[Invoice::Status::ISSUED] || 0,
            paid_count: grouped_invoices[Invoice::Status::PAID] || 0,
            voided_count: grouped_invoices[Invoice::Status::VOIDED] || 0)
        end
      end

      find_by_organisation_id(iam_tenant_id: iam_tenant_id, organisation_id: organisation_id)
    end

    def regenerate(iam_tenant_id:, organisation_id:,
                   event_occurred_at: Time.current, current_time: Time.current)
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction(transaction_isolation: :repeatable_read) do
          summary = Models::InvoiceStatusSummary
            .where('generated_at <= ?', event_occurred_at)
            .lock('FOR UPDATE NOWAIT')
            .find_by!(iam_tenant_id: iam_tenant_id, organisation_id: organisation_id)

          grouped_invoices = Models::Invoice
            .where(iam_tenant_id: iam_tenant_id, organisation_id: organisation_id).group(:status)
            .count

          summary.update!(
            generated_at: current_time.utc,
            draft_count: grouped_invoices[Invoice::Status::DRAFT] || 0,
            issued_count: grouped_invoices[Invoice::Status::ISSUED] || 0,
            paid_count: grouped_invoices[Invoice::Status::PAID] || 0,
            voided_count: grouped_invoices[Invoice::Status::VOIDED] || 0)
        end
      end

      nil
    rescue ActiveRecord::RecordNotFound
      find_by_organisation_id(iam_tenant_id: iam_tenant_id, organisation_id: organisation_id)
    rescue ActiveRecord::LockWaitTimeout => error
      raise Accountify::NotAvailable.new,
        "Resource temporarily unavailable. Original error: #{error.message}"
    end

    def find_by_organisation_id(iam_tenant_id:, organisation_id:)
      ActiveRecord::Base.connection_pool.with_connection do
        summary = Models::InvoiceStatusSummary
          .find_by!(iam_tenant_id: iam_tenant_id, organisation_id: organisation_id)

        {
          id: summary.id,
          generated_at: summary.generated_at,
          draft_count: summary.draft_count,
          issued_count: summary.issued_count,
          paid_count: summary.paid_count,
          voided_count: summary.voided_count,
          created_at: summary.created_at,
          updated_at: summary.updated_at
        }
      end
    end
  end
end
