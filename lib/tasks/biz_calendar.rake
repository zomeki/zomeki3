namespace :zomeki do
  namespace :biz_calendar do
    desc 'Publish this month'
    task(:publish_this_month => :environment) do
      Cms::Node.public_state.where(model: 'BizCalendar::Place').each do |node|
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}")
      end
    end
  end
end
