module Accountify
  module Models
    class Invoice < ActiveRecord::Base
      self.table_name = 'accountify_invoices'

      validates :organisation_id, presence: true

      has_many :line_items, -> { order(id: :asc) }

      has_many :events, -> { order(created_at: :asc) }, as: :eventable, class_name: '::Models::Event'

      has_one :invoice_status_summary

      class LineItem < ActiveRecord::Base; end
    end
  end
end
