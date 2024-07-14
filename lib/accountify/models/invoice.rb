module Accountify
  module Models
    class Invoice < ActiveRecord::Base
      self.table_name = 'accountify_invoices'

      class LineItem < ActiveRecord::Base; end

      has_many :line_items, -> { order(id: :asc) }

      has_many :events, -> { order(created_at: :asc) },
        as: :eventable, class_name: '::Event'

      has_one :invoice_status_summary
    end
  end
end
