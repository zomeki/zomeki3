Core.initialize

if Core.proxy.present?
  ENV['http_proxy'] = Core.proxy
  begin
    proxy = URI.parse(Core.proxy)
    Garb.proxy_address = proxy.host
    Garb.proxy_port = proxy.port
    Garb.proxy_user = proxy.user
    Garb.proxy_password = proxy.password
  rescue
    puts 'failed to parse proxy url.'
  end
end
