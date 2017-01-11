class AdBanner::Script::ClicksController < ApplicationController
  def pull
    ApplicationRecordSlave.each_slaves do
      AdBanner::Slave::Click.find_each do |click|
        AdBanner::Click.create(click.attributes.except('id'))
        click.destroy
      end
    end
    render plain: 'OK'
  end
end
