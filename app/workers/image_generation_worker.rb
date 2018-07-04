class ImageGenerationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, backtrace: true, expires_in: 1.hour

  attr_accessor :site

  def perform(site_id, url)
    @site = Site.find_by_id(site_id)
    return false if @site.blank?
    if url.present?
      @captured_site = Site.find_by(url: url)
      @captured_site = nil if @captured_site&.image.blank? || !@captured_site&.image.attached?
    end

    image_generator = ImageGeneratorService.new(@site, @captured_site)
    image_generator.process
  end
end
