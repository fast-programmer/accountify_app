module Accountify
  module Models
    class Contact < ActiveRecord::Base
      self.table_name = 'accountify_contacts'

      has_many :events, -> { order(created_at: :asc) }, as: :eventable
    end
  end
end
