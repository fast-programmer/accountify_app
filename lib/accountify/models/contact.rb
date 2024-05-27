module Accountify
  module Models
    class Contact < ActiveRecord::Base
      self.table_name = 'accountify_contacts'

      has_many :events, -> { order(created_at: :asc) },
        as: :eventable, class_name: 'Models::Event'
    end
  end
end
