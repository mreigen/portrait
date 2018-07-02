require 'rails_helper'
RSpec.describe ImageGenerationWorker, type: :worker do
  it { is_expected.to be_processed_in :portrait_normal }
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
  end
end
