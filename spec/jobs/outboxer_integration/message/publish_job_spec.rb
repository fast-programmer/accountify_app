require 'rails_helper'

module OutboxerIntegration
  module Message
    RSpec.describe PublishJob, type: :job do
      let(:user_id) { 123 }
      let(:tenant_id) { 456 }

      let(:current_time) { Time.now }

      let(:accountify_organisation) do
        create(:accountify_organisation, tenant_id: tenant_id)
      end

      let(:accountify_contact) do
        create(:accountify_contact,
          tenant_id: tenant_id, organisation_id: organisation.id)
      end

      let(:accountify_invoice) do
        create(:accountify_invoice,
          tenant_id: tenant_id, organisation_id: organisation.id, contact_id: contact.id)
      end

      describe 'when Accountify::Organisation::CreatedEvent' do
        let(:event) do
          create(
            :accountify_organisation_created_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            body: { 'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Organisation::CreatedEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::GenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::GenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id )])])
        end
      end

      describe 'when Accountify::Invoice::DraftedEvent' do
        let(:event) do
          create(
            :accountify_invoice_drafted_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Invoice::DraftedEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end

      describe 'when Accountify::Invoice::UpdatedEvent' do
        let(:event) do
          create(
            :accountify_invoice_updated_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Invoice::UpdatedEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end

      describe 'when Accountify::Invoice::IssuedEvent' do
        let(:event) do
          create(
            :accountify_invoice_issued_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Invoice::IssuedEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end

      describe 'when Accountify::Invoice::PaidEvent' do
        let(:event) do
          create(
            :accountify_invoice_paid_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Invoice::PaidEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end

      describe 'when Accountify::Invoice::VoidedEvent' do
        let(:event) do
          create(
            :accountify_invoice_voided_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Invoice::VoidedEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end

      describe 'when Accountify::Invoice::DeletedEvent' do
        let(:event) do
          create(
            :accountify_invoice_deleted_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          PublishJob.new.perform({
            'messageable_type' => 'Accountify::Invoice::DeletedEvent',
            'messageable_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end
    end
  end
end
