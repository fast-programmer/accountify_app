module Models
  class Event < ActiveRecord::Base
    self.table_name = 'events'

    belongs_to :eventable, polymorphic: true

    # after_create do |event|
    #   Outboxer::Message.backlog(messageable_type: event.class.name, messageable_id: event.id)
    # end
  end
end
