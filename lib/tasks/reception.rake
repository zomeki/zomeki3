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
          line = i + 2

          unless course = Reception::Course.find_by(title: row['講座名'])
            puts "can't find course at line #{line}: #{row['講座名']}"
            next
          end
          unless open = course.opens.find_by(open_on: row['開催日'])
            puts "can't find open at line #{line}: #{row['開催日']}"
            next
          end

          applicant = course.applicants.where(seq_no: row['受付番号']).first_or_initialize
          applicant.attributes = {
            open_id: open.id,
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
          }
          if applicant.invalid?
            puts "invalid applicant at line #{line}: #{applicant.errors.full_messages}"
          end
          applicants << applicant
        end

        if !ENV['DRY_RUN'] && applicants.all?(&:valid?) && applicants.size == rows.size
          applicants.each { |applicant| applicant.save(validate: false) }
        end
      end
    end
  end
end
