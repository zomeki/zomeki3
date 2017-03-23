namespace :zomeki do
  namespace :reception do
    namespace :applicants do
      desc 'Import applicants from csv'
      task :import_csv => :environment do
        require 'csv'
        require 'nkf'

        applicants = []
        rows = CSV.parse(NKF.nkf("-w", File.read(ENV['FILE'])), headers: true)
        rows.each_with_index do |row, i|
          course = Reception::Course.find_by(title: row['講座名'])
          open = course ? course.opens.find_by(open_on: row['開催日']) : nil
          applicant = Reception::Applicant.new(
            open_id: open.try(:id),
            seq_no: row['受付番号'] || 0,
            state: Reception::Applicant::STATE_OPTIONS.assoc(row['状態']).try(:last),
            name: row['名前'].to_s,
            kana: row['フリガナ'].to_s,
            tel: row['電話番号'].to_s,
            email: row['E-mail'].to_s,
            remark: row['備考'].to_s,
            applied_from: Reception::Applicant::APPLIED_FROM_OPTIONS.assoc(row['申込方法']).try(:last),
            applied_at: row['申込日時'] || Time.now,
            remote_addr: row['IPアドレス'],
            user_agent: row['ユーザーエージェント'],
          )
          if applicant.invalid?
            puts "##{i+2} is invalid: #{applicant.errors.full_messages}"
          end
          applicants << applicant
        end

        if !ENV['DRY_RUN'] && applicants.all?(&:valid?)
          applicants.each { |applicant| applicant.save(validate: false) }
        end
      end
    end
  end
end
