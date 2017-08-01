module Cms::LinkHelper
  def preview_links(site, pc_uri, sp_uri, mb_uri)
    html = []
    html << link_to_if(pc_uri.present?, 'PC', pc_uri, target: '_blank')
    html << link_to_if(sp_uri.present?, 'スマホ', sp_uri, target: '_blank') if site.use_smart_phone_feature?
    html << link_to_if(mb_uri.present?, '携帯', mb_uri, target: '_blank') if site.use_mobile_feature?
    html.join('&nbsp;').html_safe
  end
end
