require 'hashie/mash'

require 'hook_bootstrapper'

describe HookBootstrapper do
  let(:client) { double('GitHub Client') }
  let(:bootstrapper) { described_class.new(client, callback_url) }

  let(:repository) { 'xoebus/test' }
  let(:callback_url) { 'http://example.com/cla' }

  let(:our_hook) do
    Hashie::Mash.new(config: {
        url: callback_url
    })
  end

  let(:other_hook) do
    Hashie::Mash.new(config: {
        url: 'http://not.example.com/cla'
    })
  end

  describe 'bootstrapping service hooks for repositories' do
    context 'when the hook does not already exist' do
      before do
        client.stub(hooks: [other_hook])
      end

      it 'creates the service hook' do
        client.should_receive(:create_hook).with(
            repository,
            'web',
            { url: callback_url, content_type: 'json' },
            { events: %w(pull_request), active: true }
        )

        bootstrapper.bootstrap_repository(repository)
      end
    end

    context 'when the hook already exists' do
      before do
        client.stub(hooks: [our_hook])
      end

      it 'does not create a new one' do
        client.should_not_receive(:create_hook)

        bootstrapper.bootstrap_repository(repository)
      end
    end
  end
end