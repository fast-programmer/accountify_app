module Accountify
  class InvoiceStatusSummary < ApplicationRecord
    self.table_name = 'accountify_invoice_status_summaries'

    validates :organisation_id, presence: true

    validates :drafted_count,
      presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    validates :issued_count,
      presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    validates :paid_count,
      presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    validates :voided_count,
      presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    validates :generated_at,
      presence: true

    belongs_to :organisation
  end
end
