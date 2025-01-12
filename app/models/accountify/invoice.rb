module Accountify
  class Invoice < ActiveRecord::Base
    self.table_name = 'accountify_invoices'

    module Status
      DRAFTED = 'drafted'
      ISSUED = 'issued'
      PAID = 'paid'
      VOIDED = 'voided'
    end

    validates :organisation_id, presence: true

    has_many :line_items, -> { order(id: :asc) }, class_name: 'Accountify::InvoiceLineItem'

    has_many :events, -> { order(created_at: :asc) }, as: :eventable

    has_one :invoice_status_summary
  end
end
