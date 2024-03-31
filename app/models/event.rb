class Event < ActiveRecord::Base
  after_create do |event|
    Outboxer::Message.backlog!(messageable_type: event.class.name, messageable_id: event.id)
  end
end
