class Event < ActiveRecord::Base
  self.table_name = 'events'

  # associations

  belongs_to :eventable, polymorphic: true

  # validations

  validates :user_id, presence: true
  validates :tenant_id, presence: true

  validates :type, presence: true, length: { maximum: 255 }

  validates :eventable_type, presence: true, length: { maximum: 255 },
    if: -> { eventable_id.present? }

  validates :eventable_id, presence: true, if: -> { eventable_type.present? }
end
