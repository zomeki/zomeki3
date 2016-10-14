class Cms::Public::TalkController < ApplicationController
  def down_m3u
    uri  = sound_uri
    data = "#{uri}\n"
    send_data data, {:type => 'audio/x-mpegurl', :filename => 'sound.m3u', :disposition => 'inline'}
  end
  
  def down_mp3
    return render plain: '1' if params[:file_check] == '1'

    uri = Core.request_uri.gsub(/\.mp3\z/, '').gsub(/\.r\z/, '')
    return http_error(404) if ::File.extname(uri) != '.html'

    return http_error(404) if Core.script_uri.blank?
    uri = "#{Core.script_uri.gsub(/\A(.*?\/\/.*?)\/.*/, '\1')}#{uri}"
    options = uri =~ /\Ahttps:/ ? {:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE} : {}
    session_key = Rails.application.config.session_options[:key]
    options.merge!("Cookie" => "#{session_key}=#{CGI.escape(cookies[session_key])}")
    res = Util::Http::Request.send(uri, options)

    return http_error(404) if res.status != 200

    site_id = Page.site.id rescue nil

    jtalk = Cms::Lib::Navi::Jtalk.new
    jtalk.make res.body, {:site_id => site_id}
    file = jtalk.output
    send_file(file[:path], :type => file[:mime_type], :filename => 'sound.mp3', :disposition => 'inline')
    
    #file = "#{Rails.root}/ext/making.mp3"
    #send_file file, :type => 'audio/mp3', :filename => 'sound.mp3', :disposition => 'inline'
    
    #gtalk = Cms::Lib::Navi::Gtalk.new
    #gtalk.make "只今、音声を作成しています。しばらくお待ち頂いてから、もう一度、アクセスしてください"
    #file = gtalk.output
    #send_data file[:path], :type => file[:path], :filename => 'sound.mp3', :disposition => 'inline'
  end

  def sound_uri
    uri = Core.request_uri
    if uri =~ /\.m3u\z/
      uri = uri.gsub(/.m3u\z/, '.mp3')
    end
    if uri =~ /\.html\.r\.mp3\z/
      uri = uri.gsub(/\.r\.mp3\z/, '.mp3')
    end
    Page.site.full_uri + uri.slice(1, uri.size)
  end
  
  def send_sound(file)
    file = "#{Rails.root}/public/_common/sounds/#{file}"
    send_file(file, :type => 'audio/mp3', :filename => 'sound.mp3', :disposition => 'inline')
  end
end
