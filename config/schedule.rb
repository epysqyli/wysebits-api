env :PATH, ENV['PATH']
set :output, 'log/cron.log'
set :environment, 'production'

every 1.day do
  runner 'RecommendedBooksJob.perform_later'
end

every 7.days do
  runner 'WeekTrendJob.perform_later'
end

every '30 12 6 * *' do
  runner 'ImportResourcesJob.perform_later'
end

every '0 4 8 * *' do
  runner 'ElasticImportBooksJob.perform_later'
end
