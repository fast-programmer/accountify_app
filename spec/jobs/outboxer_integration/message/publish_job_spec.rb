require 'rails_helper'

module OutboxerIntegration
  module Message
    RSpec.describe PublishJob, type: :job do
      describe '#perform' do
        context 'when Accountify::Models::Invoice::DraftedEvent' do
          let(:args) do
            {
              'messageable_type' => 'Accountify::Models::Invoice::DraftedEvent',
              'messageable_id' => '123'
            }
          end

          it 'performs Accountify::Invoice::DraftedJob async' do
            PublishJob.new.perform(args)

            expect(Accountify::Invoice::DraftedJob.jobs).to match([
              hash_including('args' => [include('id' => '123')])
            ])
          end
        end

        context 'with invalid messageable_type' do
          let(:args) do
            {
              'messageable_type' => 'Wrong::Format::Test',
              'messageable_id' => '123'
            }
          end

          it 'raises an error for unexpected class name format' do
            expect {
              PublishJob.new.perform(args)
            }.to raise_error(StandardError, "Unexpected class name format: Wrong::Format::Test")
          end
        end

        context 'when job class does not exist' do
          let(:args) do
            {
              'messageable_type' => 'Accountify::Models::Invoice::NonexistentEvent',
              'messageable_id' => '123'
            }
          end

          it 'completes gracefully without raising an error' do
            allow_any_instance_of(String)
              .to receive(:constantize)
              .and_raise(NameError.new("uninitialized constant"))

            expect {
              PublishJob.new.perform(args)
            }.not_to raise_error
          end
        end
      end
    end
  end
end
