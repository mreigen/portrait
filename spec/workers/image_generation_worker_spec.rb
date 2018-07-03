require 'rails_helper'
RSpec.describe ImageGenerationWorker, type: :worker do
  it { is_expected.to be_processed_in :default }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_expired_in 1.hour }

  let!(:site) { create(:site) }

  context 'if site is found' do
    before do
      allow(Site).to receive(:find_by).with(id: site.id) { site }
    end

    it 'handles image generation' do
      expect(site.status).to eq('started')
      subject.perform(site.id)
    end

    it 'sends realtime notification with Pusher' do
      expect(Pusher).to receive(:trigger)
      subject.perform(site.id)
    end

    context 'if site has a callback_url' do
      it 'sends a webhook callback' do
        expect(HTTParty).to receive(:post).with('http://callmeback.com/later', anything)
        subject.perform(site.id)
      end
    end

    context 'if site does NOT have a callback_url' do
      before do
        allow(site).to receive(:callback_url) { nil }
      end
      it 'will NOT send a webhook callback' do
        expect(HTTParty).not_to receive(:post).with('http://callmeback.com/later', anything)
        subject.perform(site.id)
      end
    end

  end
end
