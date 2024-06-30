module Accountify
  module Models
    class AgedReceivablesReport < ActiveRecord::Base
      self.table_name = 'accountify_aged_receivables_reports'

      class Period < ActiveRecord::Base; end

      has_many :periods
    end
  end
end
