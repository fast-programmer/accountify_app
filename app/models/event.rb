class Event < ActiveRecord::Base
  include Outboxer::Messageable
end
