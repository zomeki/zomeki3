class Reception::ApplicantsScript < Cms::Script::Base
  def pull
    ApplicationRecordSlave.each_slaves do
      applicants = Reception::Slave::Applicant.all
      if ::Script.site
        open_ids = Reception::Open.where(
          course_id: Reception::Course.select(:id).where(
            content_id: Reception::Content::Course.select(:id).where(site_id: ::Script.site.id)
          )
        ).pluck(:id)
        applicants = applicants.where(open_id: open_ids)
      end

      ::Script.total = applicants.size

      applicants.find_each do |applicant|
        ::Script.progress(applicant) do
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
    end
  end
end
