module Accountify
  class Organisation < ApplicationRecord
    self.table_name = 'accountify_organisations'

    has_many :events, -> { order(created_at: :asc) }, as: :eventable

    has_one :invoice_status_summary
  end
end
