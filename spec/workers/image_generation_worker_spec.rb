require 'rails_helper'
RSpec.describe ImageGenerationWorker, type: :worker do
  it { is_expected.to be_processed_in :default }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_expired_in 1.hour }

  let!(:site) { create(:site) }

  context 'if site is found' do
    before do
      allow(Site).to receive(:find_by_id).with(site.id) { site }
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

  context 'Image Genration handling' do
    let(:site_url) { 'http://abc.com' }
    let!(:captured_site)       { create(:site, url: site_url)}
    let!(:captured_image)      { double('image') }
    let(:captured_service_url) { 'http://mysite.com/image.png' }

    context 'when the url has NOT been captured' do
      let!(:image_generator) { ImageGeneratorService.new(site) }

      before do
        allow(ImageGeneratorService).to receive(:new) { image_generator }
        allow(image_generator).to receive(:process).and_call_original
      end

      it 'calls the generator' do
        expect(image_generator).to receive(:generate_png) { 'final_url' }
        expect(image_generator).to receive(:handle).with('final_url')
        subject.perform(site.id)
      end
    end

    context 'when the url has already been captured' do
      let!(:image_generator) { ImageGeneratorService.new(site) }

      before do
        allow(ImageGeneratorService).to receive(:new) { image_generator }
        allow(image_generator).to receive(:process).and_call_original

        allow(image_generator).to receive(:captured_site) { captured_site}
        allow(captured_site).to receive(:image) { captured_image}
        allow(captured_image).to receive(:attached?) { true }
        allow(captured_image).to receive(:service_url) { captured_service_url }

      end

      it 'reuses the captured site' do
        expect(image_generator).to receive(:handle).with(captured_service_url)
        subject.perform(site.id)
      end
    end
  end

end
