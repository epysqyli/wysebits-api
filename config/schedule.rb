env :PATH, ENV['PATH']
set :output, 'log/cron.log'
set :environment, 'production'

every 7.days do
  runner 'WeekTrendJob.perform_later'
end
