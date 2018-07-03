class ImageGenerationWorker
  include Sidekiq::Worker
  include HTTParty

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
    notify_pusher
    send_webhook
  ensure
    FileUtils.rm path
  end

  def notify_pusher
    Pusher.trigger(
      'survey-monkey-test-channel',
      'image-processing-finished',
      payload
    )
  end

  def send_webhook
    return unless @site.callback_url.present?

    response = HTTParty.post(@site.callback_url, body: payload)
    if response.code == 200
      logger.info "Callback successfully sent to #{@site.callback_url}"
    else
      logger.error "Failed: Callback was sent to #{@site.callback_url} but with an error response"
    end
  rescue => e
    logger.error "Callback could not be sent to #{@site.callback_url}, error: #{e.message}"
  end

  def payload
    {
      site:
      {
        id:         @site.id,
        status:     @site.status.capitalize,
        image_name: @site.image.filename,
        image_url:  @site.image.service_url
      }
    }
  end
end
