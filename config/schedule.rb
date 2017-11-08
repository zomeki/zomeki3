# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# set :environment, 'development'
require_relative 'application'

set :output, nil

env :PATH, ENV['PATH']

# メールを取り込みます。
every '1-56/5 * * * *' do
  rake "#{ZomekiCMS::NAME}:mailin:filters:exec"
end

# 音声ファイルを静的ファイルとして書き出します。
every '6-51/15 * * * *' do
  rake "#{ZomekiCMS::NAME}:cms:talks:exec"
end

# アンケート等のデータを取り込みます。
every '9-54/15 * * * *' do
  rake "#{ZomekiCMS::NAME}:remote:data:pull"
end

# Feedコンテンツで設定したRSS・Atomフィードを取り込みます。
every :hour do
  rake "#{ZomekiCMS::NAME}:feed:feeds:read"
end

# リンクチェックを実行します。
every :hour do
  rake "#{ZomekiCMS::NAME}:cms:link_checks:exec"
end

# 不要データを削除します。
every :day, at: '0:00 am' do
  rake "#{ZomekiCMS::NAME}:sys:cleanup"
end

# アクセスランキングデータを取り込みます。
every :day, at: '0:30 am' do
  rake "#{ZomekiCMS::NAME}:rank:ranks:exec"
end

# 静的ファイルを書き出します。
every :day, at: '1:00 am' do
  rake "#{ZomekiCMS::NAME}:cms:nodes:publish"
end

# 静的ファイルを転送します。
every :day, at: '5:00 am' do
  rake "#{ZomekiCMS::NAME}:cms:file_transfers:exec"
end

# delayed_jobを再起動します。
every :sunday, at: '0:10 am' do
  rake "delayed_job:restart"
end
