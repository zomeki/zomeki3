class AdBanner::ClicksScript < Cms::Script::Base
  def pull
    ApplicationRecordSlave.each_slaves do
      clicks = AdBanner::Slave::Click.all
      if ::Script.site
        content_ids = Cms::Content.where(site_id: ::Script.site.id).pluck(:id)
        banner_ids = AdBanner::Banner.where(content_id: content_ids).pluck(:id)
        clicks.where!(banner_id: banner_ids)
      end

      ::Script.total clicks.size
      
      clicks.find_each do |click|
        ::Script.progress(click) do
          AdBanner::Click.create(click.attributes.except('id'))
          click.destroy
        end
      end
    end
  end
end
