if false #!Rails.env.development?
  YoTengoUnCine::Application.config.middleware.use(
    ExceptionNotifier,
    :email_prefix => "[YoTengoUnCine] ",
    :sender_address => APP_CONFIG[:admin_email],
    :exception_recipients => [APP_CONFIG[:admin_email]]
  )
end