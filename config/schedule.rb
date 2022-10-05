env :PATH, ENV['PATH']
set :output, 'log/cron.log'
set :environment, 'production'

every 1.day do
  runner 'RecommendedBooksJob.perform_later'
end

every 7.days do
  runner 'WeekTrendJob.perform_later'
end

every '0 0 6 * *' do
  rake "db:import_books['/home/elvis/tasks/openlibrary-diff-go/recent_works.txt']"
  rake "db:import_books['/home/elvis/tasks/openlibrary-diff-go/recent_authors.txt']"
end
