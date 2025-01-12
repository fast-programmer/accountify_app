FactoryBot.define do
  factory :event, class: 'Event' do
  end

  factory :accountify_organisation_created_event, class: 'Accountify::OrganisationCreatedEvent', parent: :event do
  end

  factory :accountify_invoice_drafted_event, class: 'Accountify::InvoiceDraftedEvent', parent: :event do
  end

  factory :accountify_invoice_updated_event, class: 'Accountify::InvoiceUpdatedEvent', parent: :event do
  end

  factory :accountify_invoice_issued_event, class: 'Accountify::InvoiceIssuedEvent', parent: :event do
  end

  factory :accountify_invoice_paid_event, class: 'Accountify::InvoicePaidEvent', parent: :event do
  end

  factory :accountify_invoice_voided_event, class: 'Accountify::InvoiceVoidedEvent', parent: :event do
  end

  factory :accountify_invoice_deleted_event, class: 'Accountify::InvoiceDeletedEvent', parent: :event do
  end
end
