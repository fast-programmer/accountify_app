module Accountify
  module Models
    class Organisation < ActiveRecord::Base
      self.table_name = 'accountify_organisations'

      has_many :events, -> { order(created_at: :asc) }, as: :eventable, class_name: '::Models::Event'

      has_one :invoice_status_summary
    end
  end
end
