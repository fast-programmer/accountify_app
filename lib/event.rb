class Event < ActiveRecord::Base
  self.table_name = 'events'

  # validations

  validates :iam_user_id, :iam_tenant_id, presence: true
  validates :eventable_type, :eventable_id, presence: true

  # associations

  belongs_to :eventable, polymorphic: true

  # callbacks

  # after_create do |event|
  #   Outboxer::Message.queue(messageable: event)
  # end
end
