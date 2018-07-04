class ImageGeneratorService
  attr_accessor :site, :captured_site

  def initialize(site)
    @site = site
  end

  def process
    if captured_site.present? && captured_site.image.attached?
      handle captured_site.image.service_url
    else
      handle generate_png
    end
  end

  private

  # Set the png located at path to the image
  def handle(path)
    if File.exist?(path)
      attach(path)
    else
      if File.exist?(local_tmp_image_file)
        attach(local_tmp_image_file)
      else
        @site.failed!
        notify
      end
    end
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
    notify
  ensure
    FileUtils.rm path
  end

  def notify
    notifier = NotifierService.new(@site)
    notifier.notify_pusher
    notifier.send_webhook
  end

  # find the already captured site that has the same url of @site
  def captured_site
    @captured_site ||= Site.where(url: @site.url).where.not(id: @site.id).last
    @captured_site = nil if @captured_site&.image.blank? || !@captured_site&.image.attached?
    @captured_site
  end

  def local_tmp_image_file
    return @local_tmp_image_file if @local_tmp_image_file.present?

    @local_tmp_image_file = "#{Rails.root}/tmp/captured_site_#{@site.id}.png"
    File.open(@local_tmp_image_file, 'wb') do |file|
      file.write(@captured_site.image.download)
    end
    @local_tmp_image_file
  end

end