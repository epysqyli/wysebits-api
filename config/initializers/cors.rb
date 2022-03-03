Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['allowed_domain']

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true
  end

  allow do
    origins ENV['allowed_domain_full']

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end
