class Mailin::DocBuilderService < ApplicationService
  def initialize(filter)
    @filter = filter
    @content = filter.content
    @dest_content = filter.dest_content
    @site = filter.content.site
  end

  def build(mail)
    doc = @dest_content.docs.build
    doc.concept_id = @dest_content.concept_id
    doc.state = 'public'
    doc.title = mail.subject
    doc.body = mail.inline_contents.map(&:to_html).join('<br />')
    doc.remark = mail.header

    [:created_at, :updated_at, :published_at, :display_updated_at, :display_published_at].each do |column|
      doc[column] = mail.date
    end

    doc.build_creator
    if (sender = find_or_create_mail_sender(mail)) 
      doc.creator.user = sender
      doc.creator.group = sender.groups.first
    end

    mail.attachments.each_with_index do |attachment, i|
      file = doc.files.build
      file.site = @site
      file.name = "#{i + 1}#{::File.extname(attachment.filename)}"
      file.title = attachment.filename
      file.created_at = doc.created_at
      file.updated_at = doc.updated_at
      file.file = Sys::Lib::File::NoUploadedFile.new(data: attachment.decoded, mime_type: attachment.mime_type)
      file.build_creator(doc.creator.attributes.except('id'))
    end

    doc.in_ignore_accessibility_check = '1'
    doc.in_ignore_link_check = '1'
    doc.keep_display_updated_at = true

    doc.save(validate: false)
    doc.files.each(&:save)

    if @dest_content.default_category
      doc.categories << @dest_content.default_category
    end

    doc
  end

  private

  def find_or_create_mail_sender(mail)
    sender = nil
    if (from = mail.from.first)
      sender = @site.users.find_by(email: from)
      sender ||= create_mail_user(from) if @filter.default_user_id.blank?
    end
    sender ||= @content.default_user || @site.managers.first || Sys::User.root
    sender
  end

  def create_mail_user(mail_address)
    ApplicationRecord.transaction do
      group = create_mail_group
      user = Sys::User.new(state: 'enabled',
                           account: mail_address,
                           name: mail_address, 
                           email: mail_address,
                           auth_no: 2,
                           ldap: 0)
      user.in_group_id = group.id
      user.save(validate: false)
      user
    end
  end

  def create_mail_group
    group = Sys::Group.new(state: 'enabled',
                           parent_id: @site.groups.root.id,
                           code: "mail_group",
                           ldap: 0,
                           level_no: 2)
    group.save(validate: false)
    group.code = group.name = group.name_en = "mail_group_#{group.id}"
    group.save(validate: false)
    group.sites << @site
    group
  end
end
