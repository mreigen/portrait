class ImageGenerationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, backtrace: true, expires_in: 1.hour

  attr_accessor :site

  def perform(site_id)
    @site = Site.find_by_id(site_id)
    return false if @site.blank?

    image_generator = ImageGeneratorService.new(@site)
    image_generator.process
  end
end
