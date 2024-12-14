FactoryBot.define do
  factory :event, class: 'Event' do
  end

  factory :accountify_organisation_created_event, class: 'Accountify::Organisation::CreatedEvent', parent: :event do
  end

  factory :accountify_invoice_drafted_event, class: 'Accountify::Invoice::DraftedEvent', parent: :event do
  end

  factory :accountify_invoice_updated_event, class: 'Accountify::Invoice::UpdatedEvent', parent: :event do
  end

  factory :accountify_invoice_issued_event, class: 'Accountify::Invoice::IssuedEvent', parent: :event do
  end

  factory :accountify_invoice_paid_event, class: 'Accountify::Invoice::PaidEvent', parent: :event do
  end

  factory :accountify_invoice_voided_event, class: 'Accountify::Invoice::VoidedEvent', parent: :event do
  end

  factory :accountify_invoice_deleted_event, class: 'Accountify::Invoice::DeletedEvent', parent: :event do
  end
end
