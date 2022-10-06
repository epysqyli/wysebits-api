env :PATH, ENV['PATH']
set :output, 'log/cron.log'
set :environment, 'production'

every 1.day do
  runner 'RecommendedBooksJob.perform_later'
end

every 7.days do
  runner 'WeekTrendJob.perform_later'
end

every '0 20 6 * *' do
  runner 'ImportResourcesJob.perform_later'
end
