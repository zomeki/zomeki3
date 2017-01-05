class Reception::Script::ApplicantsController < ApplicationController
  def pull
    ApplicationRecordSlave.each_slaves do
      Reception::Slave::Applicant.find_each do |applicant|
        case applicant.state
        when 'tmp_applied'
          item = Reception::Applicant.new(applicant.attributes.except('id'))
          item.state = 'applied'
          item.save(validate: false)
        when 'tmp_canceled'
          if (item = Reception::Applicant.where(token: applicant.token).first)
            item.state = 'canceled'
            item.save(validate: false)
          end
        end
        applicant.destroy
      end
    end
    render plain: 'OK'
  end
end
