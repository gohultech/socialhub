class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM") {
    raise "MAILER_FROM must be set in production" if Rails.env.production?

    "no-reply@socialhub.test"
  }
  layout "mailer"
end
