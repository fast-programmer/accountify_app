class Message < ApplicationRecord
  include Outboxer::Outboxable
end
