module Accountify
  module Models
    class Invoice < ActiveRecord::Base
      self.table_name = 'accountify_invoices'

      has_many :events, -> { order(created_at: :asc) },
        as: :eventable, class_name: 'Models::Event'
    end
  end
end
