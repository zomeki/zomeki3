## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
survey_form  = create_cms_content c_content, 'Survey::Form', 'お問い合わせフォーム', 'toiawase'

l_col1 = Cms::Layout.where(name: 'col-1').first
create_cms_node c_content, survey_form, 170, nil, l_col1, 'Survey::Form', 'contact', 'お問い合わせフォーム', nil

settings = Survey::Content::Setting.config(survey_form, 'captcha')
settings.value = 'enabled'
settings.save

## ---------------------------------------------------------
## survey/survey_forms

feedback = Survey::Form.create content_id: survey_form.id,
  name: 'feedback', title: '記事へのアンケート',
  summary: read_data('surveys/feedback/summary'),
  description: read_data('surveys/feedback/description'),
  sitemap_state: 'hidden', index_link: 'hidden',
  sort_no: 10, confirmation: true, state: 'public'

goiken = Survey::Form.create content_id: survey_form.id,
  name: 'goiken', title: '市へのご意見',
  summary: read_data('surveys/goiken/summary'),
  description: read_data('surveys/goiken/description'),
  receipt: read_data('surveys/goiken/reciept'),
  sitemap_state: 'visible', index_link: 'visible',
  sort_no: 20, confirmation: true, state: 'public'

def create(form, title, description, form_type, form_options, required, style_attribute, sort_no)
  Survey::Question.create form_id: form.id,
    title: title,
    description: description,
    form_type: form_type,
    form_options: form_options,
    required: required,
    style_attribute: style_attribute,
    sort_no: sort_no,
    state: 'public'
end

create feedback, '役に立ちましたか？', nil, 'radio_button', '役に立った\r役に立たなかった', true, nil, 10
create feedback, '役に立った(役に立たなかった)具体的な理由をご記入ください', nil, 'text_area', nil, true, 'width: 70%;', 20

create goiken, 'お名前', nil, 'text_field', nil, true, 'width: 300px;', 10
create goiken, '住所', nil, 'text_field', nil, true, 'width: 300px;', 20
create goiken, 'メールアドレス', '<p>半角英数字で入力ださい</p>', 'text_field_email', nil, false, 'width: 300px;', 30
create goiken, 'ご意見内容', nil,  'text_area', nil, true, 'width: 600px; height: 150px;', 40

form_piece = create_cms_piece c_site, survey_form, 'Survey::Form', 'feed-back', '記事へのアンケート', '記事へのアンケート'
form_piece.in_settings = {target_form_id: feedback.id, head_css: '<link rel="stylesheet" href="/_themes/top/style.css" />',
  upper_text: '<script src="/_common/js/jquery.iframe-auto-height.js">\n</script><script src="/_common/js/jquery.browser.js"></script>'}
form_piece.save

