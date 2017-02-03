class ReplaceNameOnSysProcesses < ActiveRecord::Migration[5.0]
  def up
    map = [
      ['cms/script/talk_tasks/exec', 'cms/talk_tasks/exec'],
      ['cms/script/nodes/publish', 'cms/nodes/publish'],
      ['ad_banner/script/clicks/pull', 'ad_banner/clicks/pull'],
      ['feed/script/feeds/read', 'feed/feeds/read'],
      ['survey/script/answers/pull', 'survey/answers/pull'],
      ['rank/script/ranks/exec', 'rank/ranks/exec'],
      ['gp_article/script/docs/publish_doc', 'gp_article/docs/publish_doc'],
    ]
    map.each do |before, after|
      execute "update sys_processes set name = replace(name, '#{before}', '#{after}')"
      execute "update sys_process_logs set name = replace(name, '#{before}', '#{after}')"
    end
  end
end
