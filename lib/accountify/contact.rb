# /db/migrate/create_accountify_organisations.rb
#   id:bigint, email:text, first_name:text, last_name:text

# /db/migrate/create_accountify_contacts.rb
#   id:bigint email:text:not_null first_name:text, last_name:text

# /db/migrate/create_accountify_invoices.rb
#   id:bigint total_amount

# /db/migrate/create_accountify_invoice_line_items.rb
# id:bigint, ....

# /db/migrate/create_events.rb
# iam_user_id:bigint, iam_account_id:bigint, id:bigint, type:text

# /db/migrate/create_outboxer_messages.rb


# type column, not null

# lib/accountify/models/organisation.rb
module Accountify
  module Models
    class Organisation < ActiveRecord::Base
      has_many :contacts
      has_many :invoices
    end
  end
end

# lib/accountify/models/organisation.rb
module Accountify
  module Models
    class Contact < ActiveRecord::Base
      belongs_to :organisation
      has_many :invoices
    end
  end
end

# lib/accountify/models/contact.rb
module Accountify
  module Models
    class Contact < ActiveRecord::Base
      belongs_to :organisation
      has_many :invoices
    end
  end
end

# lib/accountify/models/invoice.rb
module Accountify
  module Models
    class Invoice < ActiveRecord::Base
      belongs_to :organisation
      belongs_to :contact

      # total = sum of line item total
      # amount due
      # amount paid

      # invariants
      # status = paid when amount due = 0
      # status = paid when amount due = 0
      # total = amount due - amount paid
      # total = sum of line item total


      class LineItem < ActiveRecord::Base; end

      has_many :line_items
    end
  end
end

# lib/accountify/models/invoice/line_item.rb
module Accountify
  module Models
    class Invoice
    end
  end
end

# lib/models/event.rb
module Models
  class Event < ActiveRecord
  end
end

module Event
  class CreatedJob
    include Sidekiq::Job

    def perform(args)
      event = Models::Event.find(args['id'])

      logger.info "[#{event.id}] processed"
    end
  end
end

# lib/accountify/contact.rb
module Accountify
  module Contact
    extend self

    class CreatedEvent < Models::Event; end

    def create(iam_user:, iam_account:,
               id:, email:, first_name: nil, last_name: nil)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .where(iam_account_id: iam_account.id)
          .create!(email: email, first_name: first_name, last_name: last_name)

        event = CreatedEvent.create!(
          iam_user_id: iam_user_id,
          iam_account_id: iam_account.id,
          eventable: contact,
          payload: {
            'first_name' => first_name,
            'last_name' => last_name,
            'email_name' => email_name,
            'contact' => {
              'id' => contact.id,
              'first_name' => first_name,
              'last_name' => last_name,
              'email' => email } })
      end

      job_id = Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user.id,
        'iam_account_id' => iam_account.id,
        'id' => event.id,
        'type' => event.type })

      { id: id, event_id: event.id, job_id: job_id }
    end

    class UpdatedEvent < Models::Event; end

    def update(iam_user:, iam_account:,
                id:, email:, first_name:, last_name:)
      contact = nil
      event = nil

      ActiveRecord::Base.transaction do
        contact = Models::Contact
          .where(iam_account_id: iam_account.id)
          .lock
          .find_by!(id: id)

        contact.update!(first_name: first_name)

        event = UpdatedEvent.create!(
          iam_user_id: iam_user_id,
          iam_account_id: iam_account.id,
          eventable: contact,
          payload: {
            'first_name' => first_name,
            'contact' => {
              'id' => contact.id,
              'first_name' => first_name } })
      end

      job_id = Event::CreatedJob.perform_async({
        'iam_user_id' => iam_user.id,
        'iam_account_id' => iam_account.id,
        'id' => event.id,
        'type' => event.type })

      { id: id, event_id: event.id, job_id: job_id }
    end
  end
end
