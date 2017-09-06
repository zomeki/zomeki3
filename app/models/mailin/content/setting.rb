class Mailin::Content::Setting < Cms::ContentSetting
  set_config :mail,
    name: 'メールアドレス',
    form_type: :text_field,
    extra_options: {
      protocol_options: [['POP', 'pop'], ['APOP', 'apop']],
      pop_cycle_options: [5,10,15,20,25,30].map { |min| ["#{min}分", min] }
    },
    default_extra_values: {
      host: nil,
      port: '110',
      username: nil,
      password: nil,
      protocol: 'pop',
      pop_cycle: '5'
    }

  belongs_to :content, foreign_key: :content_id, class_name: 'Mailin::Content::Filter'

  def extra_values=(params)
    ex = extra_values
    case name
    when 'mail'
      ex[:host] = params[:host]
      ex[:port] = params[:port]
      ex[:username] = params[:username]
      ex[:password] = params[:password]
      ex[:protocol] = params[:protocol]
      ex[:pop_cycle] = params[:pop_cycle]
    end
    super(ex)
  end

  class << self
    def min_pop_cycle
      self.all_config(:mail)[:extra_options][:pop_cycle_options].first.last
    end
  end
end
