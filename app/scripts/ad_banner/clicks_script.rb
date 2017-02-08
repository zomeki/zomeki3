class AdBanner::ClicksScript < Cms::Script::Base
  def pull
    ApplicationRecordSlave.each_slaves do
      AdBanner::Slave::Click.find_each do |click|
        AdBanner::Click.create(click.attributes.except('id'))
        click.destroy
      end
    end
  end
end
