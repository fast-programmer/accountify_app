class Event < ApplicationRecord
  self.table_name = "events"

  # associations

  belongs_to :eventable, polymorphic: true

  # validations

  validates :type, presence: true, length: { maximum: 255 }
end
