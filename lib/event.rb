class Event < ActiveRecord::Base
  self.table_name = 'events'

  # validations

  validates :user_id, :tenant_id, presence: true
  validates :eventable_type, :eventable_id, presence: true

  # associations

  belongs_to :eventable, polymorphic: true
end
