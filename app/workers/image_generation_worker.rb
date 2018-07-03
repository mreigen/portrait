class ImageGenerationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, backtrace: true, expires_in: 1.hour

  attr_accessor :site

  def perform(site)
    @site = Site.find_by(id: site)
    handle generate_png if @site.present?
  end

  private

  # Set the png located at path to the image
  def handle(path)
    File.exist?(path) ? attach(path) : @site.failed!
  end

  def generate_png
    node      = `which node`.chomp
    file_name = "#{@site.id}-full.png"
    command   = "#{node} #{Rails.root}/app/javascript/puppeteer/generate_screenshot.js --url='#{@site.url}' --fullPage=true --omitBackground=true --savePath='#{Rails.root}/tmp/' --fileName='#{file_name}'"

    system command

    return "#{Rails.root}/tmp/#{file_name}"
  end

  def attach(path)
    @site.image.attach io: File.open(path), filename: "#{@site.id}.png", content_type: 'image/png'
    @site.succeeded!
  ensure
    FileUtils.rm path
  end
end
