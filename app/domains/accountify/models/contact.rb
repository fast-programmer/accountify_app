module Accountify
  module Models
    class Contact < ActiveRecord::Base
      self.table_name = 'accountify_contacts'

      validates :organisation_id, presence: true

      has_many :events, -> { order(created_at: :asc) }, as: :eventable, class_name: '::Models::Event'
    end
  end
end
