class Event < ActiveRecord::Base
  self.table_name = 'events'

  # Validations
  validates :iam_user_id, :iam_tenant_id, presence: true
  validates :eventable_type, :eventable_id, presence: true

  # Associations
  belongs_to :eventable, polymorphic: true

  # Callbacks
  after_create do |event|
    # Outboxer::Message.backlog(messageable_type: event.class.name, messageable_id: event.id)
  end
end
