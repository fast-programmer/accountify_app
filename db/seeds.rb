# Outboxer::Models::Exception.delete_all
Outboxer::Models::Message.destroy_all

Message.delete_all

1.times do |index|
  Message.create!(
    account_id: 1,
    user_id: 1,
    body_class_name: "Messages::Proposal::Accepted",
    body_json: { proposal: { id: index } }
  )
end
