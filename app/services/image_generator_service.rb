class ImageGeneratorService
  attr_accessor :site, :captured_site, :local_image_path

  def initialize(site, captured_site=nil)
    @site = site
    @captured_site = captured_site
  end

  def process
    if @captured_site.present? && @captured_site.image.attached?
      handle @captured_site.image.service_url
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
      local_tmp_path = "#{Rails.root}/tmp/captured_site_#{@site.id}.png"

      File.open(local_tmp_path, 'wb') do |file|
        file.write(@captured_site.image.download)
      end

      if File.exist?(local_tmp_path)
        attach(local_tmp_path)
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

end