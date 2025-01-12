module Accountify
  class Contact < ActiveRecord::Base
    self.table_name = 'accountify_contacts'

    validates :organisation_id, presence: true

    has_many :events, -> { order(created_at: :asc) }, as: :eventable
  end
end
