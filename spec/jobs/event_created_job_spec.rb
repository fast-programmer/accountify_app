require 'rails_helper'

RSpec.describe EventCreatedJob, type: :job do
  let(:tenant_id) { 555 }

  describe 'when Accountify::Organisation::CreatedEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Organisation::CreatedEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::GenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::GenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end

  describe 'when Accountify::Invoice::DraftedEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Invoice::DraftedEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end

  describe 'when Accountify::Invoice::UpdatedEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Invoice::UpdatedEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end

  describe 'when Accountify::Invoice::IssuedEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Invoice::IssuedEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end

  describe 'when Accountify::Invoice::PaidEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Invoice::PaidEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end
  describe 'when Accountify::Invoice::VoidedEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Invoice::VoidedEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end

  describe 'when Accountify::Invoice::DeletedEvent' do
    before do
      EventCreatedJob.new.perform({
        'tenant_id' => tenant_id,
        'type' => 'Accountify::Invoice::DeletedEvent' })
    end

    it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
      expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
        hash_including(
          'args' => [
            hash_including(
              'tenant_id' => tenant_id )])])
    end
  end
end
