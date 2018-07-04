class NotifierService
  include HTTParty

  attr_accessor :site

  def initialize(site)
    @site = site
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
      Rails.logger.info "Callback successfully sent to #{@site.callback_url}"
    else
      Rails.logger.error "Failed: Callback was sent to #{@site.callback_url} but with an error response"
    end
  rescue => e
    Rails.logger.error "Callback could not be sent to #{@site.callback_url}, error: #{e.message}"
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