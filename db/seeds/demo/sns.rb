## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
sns_share  = create_cms_content c_content, 'SnsShare::Account', 'SNSシェア', 'sns_share'

SnsShare::Account.create content_id: sns_share.id, provider: 'facebook'
SnsShare::Account.create content_id: sns_share.id, provider: 'twitter'

