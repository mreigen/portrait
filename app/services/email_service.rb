class EmailService
  class << self
    include Urlable

    def do_send_mail user, mail, token=nil
      return if mail.blank?
      return if Rails.env == 'test'

      client = SendGrid::Client.new do |c|
        c.api_user = ENV['SENDGRID_USERNAME']
        c.api_key  = ENV['SENDGRID_PASSWORD']
      end

      if token.present? && client.send(mail).code == 200
        user.update(reset_password_token: token)
      end
    end

    def compose_password_reset_email user, token
      change_password_link = change_password_link(user, 'here', token)
      return SendGrid::Mail.new do |m|
        m.to      = user.email
        m.from    = 'info@portrait.com'
        m.subject = "Reset password link for #{user.name}"
        m.html    = "Hi #{user.name}! We received a request to change your password. If you have issued this request, click #{change_password_link} to change your password."
      end
    end

    def send_password_reset_email user
      return if Rails.env == 'test'
      token = generate_reset_password_token
      mail  = compose_password_reset_email(user, token)
      do_send_mail(user, mail, token)
    end

    private

    def generate_reset_password_token
      ('a'..'z').to_a.shuffle[0,8].join
    end
  end

end