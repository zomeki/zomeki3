class Cms::Site < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Page

  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::DataFile
  include Sys::Model::Rel::FileTransfer
  include Cms::Model::Rel::SiteSetting

  include StateText

  OGP_TYPE_OPTIONS = [['article', 'article'], ['product', 'product'], ['profile', 'profile']]
  SMART_PHONE_PUBLICATION_OPTIONS = [['書き出さない', 'no'], ['書き出す', 'yes']]
  SPP_TARGET_OPTIONS = [['トップページのみ書き出す', 'only_top'], ['すべて書き出す', 'all']]

  belongs_to :status, :foreign_key => :state,
    :class_name => 'Sys::Base::Status'
  has_many :concepts, -> { order(:sort_no, :name, :id) }, :foreign_key => :site_id,
    :class_name => 'Cms::Concept', :dependent => :destroy
  has_many :contents, -> { order(:sort_no, :name, :id) }, :foreign_key => :site_id,
    :class_name => 'Cms::Content'
  has_many :settings, -> { order(:name, :sort_no) }, :foreign_key => :site_id,
    :class_name => 'Cms::SiteSetting'
  has_many :basic_auth_users, -> { order(:name) }, :foreign_key => :site_id,
    :class_name => 'Cms::SiteBasicAuthUser'
  has_many :kana_dictionaries, :foreign_key => :site_id,
    :class_name => 'Cms::KanaDictionary'
  has_many :site_belongings, :dependent => :destroy, :class_name => 'Cms::SiteBelonging'
  has_many :groups, :through => :site_belongings, :class_name => 'Sys::Group'
  has_many :nodes, :dependent => :destroy
  has_many :messages, class_name: 'Sys::Message', dependent: :destroy
  has_many :operation_logs, class_name: 'Sys::OperationLog'
  has_many :transferred_files, class_name: 'Sys::TransferredFile'
  has_many :transferable_files, class_name: 'Sys::TransferableFile'
  belongs_to :root_node, foreign_key: :node_id, class_name: 'Cms::Node'

  # conditional relations
  has_many :root_concepts, -> { where(level_no: 1).order(:sort_no, :name, :id) },
    class_name: 'Cms::Concept'
  has_many :public_root_concepts, -> { where(level_no: 1, state: 'public').order(:sort_no, :name, :id) },
    class_name: 'Cms::Concept'
  has_many :admin_protocol_settings, class_name: 'Cms::SiteSetting::AdminProtocol'
  has_many :emergency_layout_settings, class_name: 'Cms::SiteSetting::EmergencyLayout'

  validates :state, :name, presence: true
  validates :full_uri, presence: true, uniqueness: true, url: true
  validates :mobile_full_uri, uniqueness: true, url: true, if: -> { mobile_full_uri.present? }
  validates :admin_full_uri, uniqueness: true, url: true, if: -> { admin_full_uri.present? }

  after_initialize :set_defaults

  ## site image
  attr_accessor :site_image, :del_site_image
  attr_accessor :in_root_group_id

  after_save { save_cms_data_file(:site_image, :site_id => id) }
  after_destroy { destroy_cms_data_file(:site_image) }

  ## file transfer
  after_save { save_file_transfer(:site_id => id) }

  ## site settings
  after_save { save_site_settings(:site_id => id) }

  before_validation :fix_full_uri
  before_destroy :block_last_deletion

  after_save :generate_files
  after_destroy :destroy_files
  after_save :generate_apache_configs
  after_destroy :destroy_apache_configs
  after_destroy :destroy_apache_admin_configs
  after_save :generate_nginx_configs
  after_destroy :destroy_nginx_configs
  after_destroy :destroy_nginx_admin_configs

  after_create :make_concept
  after_create :make_site_belonging
  after_save :make_node
  after_save :copy_common_directory

  def states
    [['公開','public']]
  end

  def root_path
    dir = format('%04d', id)
    Rails.root.join("sites/#{dir}")
  end

  def public_path
    "#{root_path}/public"
  end

  def public_smart_phone_path
    "#{public_path}/_smartphone"
  end

  def config_path
    "#{root_path}/config"
  end

  def rewrite_config_path
    "#{config_path}/rewrite.conf"
  end

  def uri
    return '/' unless full_uri.match(/^[a-z]+:\/\/[^\/]+\//)
    full_uri.sub(/^[a-z]+:\/\/[^\/]+\//, '/')
  end

  def domain
    URI.parse(full_uri.to_s).host
  end

  def mobile_domain
    URI.parse(mobile_full_uri.to_s).host
  end

  def admin_domain
    URI.parse(admin_full_uri.to_s).host
  end

  def public_domains
    [domain, mobile_domain].select(&:present?).uniq
  end

  def admin_domains
    [admin_domain].select(&:present?).uniq
  end

  def publish_uri
    "#{Core.full_uri}_publish/#{format('%04d', id)}/"
  end

  def full_ssl_uri
    return nil unless use_common_ssl?
    url  = Sys::Setting.setting_extra_value(:common_ssl, :common_ssl_uri)
    url += "_ssl/#{format('%04d', id)}/"
    return url
  end

  def has_mobile?
    !mobile_full_uri.blank?
  end

  def site_domain?(script_uri)
    return false if Cms::SiteSetting::AdminProtocol.core_domain?
    parsed_uri = Addressable::URI.parse(script_uri)
    parsed_uri.path = '/'

    parsed_uri.scheme = 'http'
    http_base = parsed_uri.to_s
    parsed_uri.scheme = 'https'
    https_base = parsed_uri.to_s
    return true if site_domains.index(http_base).present? || site_domains.index(https_base).present?
    return false
  end

  def site_domains
    domains = []
    domains << "#{full_uri}" if !full_uri.blank?
    domains << "#{mobile_full_uri}" if !mobile_full_uri.blank?
    domains << "#{admin_full_uri}" if !admin_full_uri.blank?
    domains
  end

  def related_sites(options = {})
    sites = []
    related_site.to_s.split(/(\r\n|\n)/).each do |line|
      sites << line if line.strip != ''
    end
    if options[:include_self]
      sites << "#{full_uri}" if !full_uri.blank?
      sites << "#{mobile_full_uri}" if !mobile_full_uri.blank?
    end
    sites
  end

  def site_image_uri
    cms_data_file_uri(:site_image, :site_id => id)
  end

  def self.all_with_full_uri(full_uri)
    parsed_uri = Addressable::URI.parse(full_uri)
    parsed_uri.path = '/'
    parsed_uri.query = nil
    parsed_uri.fragment = nil

    parsed_uri.scheme = 'http'
    http_base = parsed_uri.to_s
    parsed_uri.scheme = 'https'
    https_base = parsed_uri.to_s
    sites = self.arel_table
    if Cms::SiteSetting::AdminProtocol.core_domain?
      self.where(sites[:full_uri].matches("#{http_base}%")
                     .or(sites[:full_uri].matches("#{https_base}%"))
                     .or(sites[:mobile_full_uri].matches("#{http_base}%"))
                     .or(sites[:mobile_full_uri].matches("#{https_base}%")))
          .order(:id)
    else
      self.where(sites[:full_uri].matches("#{http_base}%")
                     .or(sites[:full_uri].matches("#{https_base}%"))
                     .or(sites[:mobile_full_uri].matches("#{http_base}%"))
                     .or(sites[:mobile_full_uri].matches("#{https_base}%"))
                     .or(sites[:admin_full_uri].matches("#{http_base}%"))
                     .or(sites[:admin_full_uri].matches("#{https_base}%")))
          .order(:id)
    end
  end

  def self.make_virtual_hosts_config
    conf = '';
    order(:id).each do |site|
      next unless ::File.exist?(site.public_path)
      next unless ::File.exist?(site.config_path + "/rewrite.conf")

      domain = site.domain
      next unless domain.to_s =~ /^[1-9a-z\.\-\_]+$/i

      conf.concat(<<-EOT)
<VirtualHost *:80>
    ServerName #{domain}
      EOT

      if (md = site.mobile_domain).to_s =~ /^[1-9a-z\.\-\_]+$/i
        conf.concat(<<-EOT)
    ServerAlias #{md}
    SetEnvIf Host #{Regexp.quote(md)} MOBILE_SITE
        EOT
      end

      conf.concat(<<-EOT)
    AddType text/x-component .htc
    Alias /_common/ "#{Rails.root}/public/_common/"
    DocumentRoot #{site.public_path}
    Include #{Rails.root}/config/rewrite/base.conf
    Include #{site.config_path}/rewrite.conf
</VirtualHost>

      EOT
    end
    conf
  end

 def self.put_virtual_hosts_config
    conf = make_virtual_hosts_config
    Util::File.put virtual_hosts_config_path, data: conf
    FileUtils.touch reload_virtual_hosts_text_path
  end

  def self.virtual_hosts_config_path
    Rails.root.join('config/virtual-hosts/sites.conf')
  end

  def self.reload_virtual_hosts_text_path
    Rails.root.join('tmp/reload_virtual_hosts.txt')
  end

  def self.generate_apache_configs
    all.each(&:generate_apache_configs)
  end

  def generate_apache_configs
    virtual_hosts = Rails.root.join('config/apache/virtual_hosts')
    unless (template = virtual_hosts.join('template.conf.erb')).file?
      logger.warn 'VirtualHost template not found.'
      return false
    end
    erb = ERB.new(template.read, nil, '-').result(binding)
    virtual_hosts.join("site_#{'%04d' % id}.conf").write erb
  end

  def destroy_apache_configs
    conf = Rails.root.join("config/apache/virtual_hosts/site_#{'%04d' % id}.conf")
    return false unless conf.exist?
    conf.delete
  end

  def self.generate_apache_admin_configs
    all.each(&:generate_apache_admin_configs)
  end

  def generate_apache_admin_configs
    return if admin_domain.blank?
    virtual_hosts = Rails.root.join('config/apache/admin_virtual_hosts')
    unless (template = virtual_hosts.join('template.conf.erb')).file?
      logger.warn 'VirtualHost template not found.'
      return false
    end
    erb = ERB.new(template.read, nil, '-').result(binding)
    virtual_hosts.join("site_#{'%04d' % id}.conf").write erb
  end

  def destroy_apache_admin_configs
    conf = Rails.root.join("config/apache/admin_virtual_hosts/site_#{'%04d' % id}.conf")
    return false unless conf.exist?
    conf.delete
  end

  def self.reload_nginx_servers
    FileUtils.touch reload_servers_text_path
  end

  def self.reload_servers_text_path
    Rails.root.join('tmp/reload_servers.txt')
  end

  def self.generate_nginx_configs
    all.each(&:generate_nginx_configs)
  end

  def generate_nginx_configs
    servers = Rails.root.join('config/nginx/servers')
    unless (template = servers.join('template.conf.erb')).file?
      logger.warn 'Server template not found.'
      return false
    end
    erb = ERB.new(template.read, nil, '-').result(binding)
    servers.join("site_#{'%04d' % id}.conf").write erb
  end

  def self.generate_nginx_admin_configs
    all.each(&:generate_nginx_admin_configs)
  end

  def generate_nginx_admin_configs
    servers = Rails.root.join('config/nginx/admin_servers')
    unless (template = servers.join('template.conf.erb')).file?
      logger.warn 'Server template not found.'
      return false
    end
    erb = ERB.new(template.read, nil, '-').result(binding)
    conf_file = servers.join("site_#{'%04d' % id}.conf")
    if admin_domain.blank?
      FileUtils.rm_f(conf_file)
    else
      conf_file.write erb
    end
  end

  def destroy_nginx_configs
    conf = Rails.root.join("config/nginx/servers/site_#{'%04d' % id}.conf")
    return false unless conf.exist?
    conf.delete
  end

  def destroy_nginx_admin_configs
    conf = Rails.root.join("config/nginx/admin_servers/site_#{'%04d' % id}.conf")
    return false unless conf.exist?
    conf.delete
  end

  def basic_auth_user_enabled?
    basic_auth_users.root_location.enabled.exists?
  end

  def system_basic_auth_user_enabled?
    basic_auth_users.system_location.enabled.exists?
  end

  def directory_basic_auth_user_enabled?(directory)
    basic_auth_users.directory_location.enabled.where(target_location: directory).exists?
  end

  def basic_auth_enabled?
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"
    return ::File.exists?(pw_file)
  end

  def system_basic_auth_enabled?
    pw_file = "#{::File.dirname(public_path)}/.htpasswd_system"
    return ::File.exists?(pw_file)
  end

  def directory_basic_auth_enabled?(directory)
    pw_file = "#{::File.dirname(public_path)}/.htpasswd_#{directory}"
    return ::File.exists?(pw_file)
  end

  def enable_basic_auth
    self.load_site_settings
    self.in_setting_site_basic_auth_state = 'enabled'
    self.save

    ac_file = "#{::File.dirname(public_path)}/.htaccess"
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"

    conf  = %Q(<FilesMatch "^(?!#{ZomekiCMS::ADMIN_URL_PREFIX})">\n)
    conf += %Q(    AuthUserFile #{pw_file}\n)
    conf += %Q(    AuthGroupFile /dev/null\n)
    conf += %Q(    AuthName "Please enter your ID and password"\n)
    conf += %Q(    AuthType Basic\n)
    conf += %Q(    require valid-user\n)
    conf += %Q(    allow from all\n)
    conf += %Q(</FilesMatch>\n)
    #conf += %Q(<FilesMatch "^_dynamic">\n)
    #conf += %Q(    Order allow,deny\n)
    #conf += %Q(    Allow from All\n)
    #conf += %Q(    Satisfy Any\n)
    #conf += %Q(</FilesMatch>\n)
    Util::File.put(ac_file, :data => conf)

    salt = Zomeki.config.application['sys.crypt_pass']
    conf = ""
    basic_auth_users.root_location.enabled.each do |user|
      conf += %Q(#{user.name}:#{user.password.crypt(salt)}\n)
    end

    Util::File.put(pw_file, :data => conf)
    enable_system_basic_auth(salt)
    enable_directory_basic_auth(salt)
    generate_nginx_configs
    generate_nginx_admin_configs
    Cms::Site.reload_nginx_servers
    return true
  end

  def enable_system_basic_auth(salt)
    system_pw_file = "#{::File.dirname(public_path)}/.htpasswd_system"
    if auth_users = basic_auth_users.system_location.enabled
      conf = ""
      auth_users.system_location.where(state: 'enabled').each do |user|
        conf += %Q(#{user.name}:#{user.password.crypt(salt)}\n)
      end
      Util::File.put(system_pw_file, :data => conf)
    end
  end

  def enable_directory_basic_auth(salt)
    if auth_users = basic_auth_users.directory_auth
      auth_users.each do |d|
        directory_pw_file = "#{::File.dirname(public_path)}/.htpasswd_#{d.target_location}"
        conf = ""
        basic_auth_users.directory_location.enabled.where(target_location: d.target_location).each do |user|
          conf += %Q(#{user.name}:#{user.password.crypt(salt)}\n)
        end
        Util::File.put(directory_pw_file, :data => conf)
      end
    end
  end

  def disable_basic_auth
    self.load_site_settings
    self.in_setting_site_basic_auth_state = 'disabled'
    self.save
    ac_file = "#{::File.dirname(public_path)}/.htaccess"
    FileUtils.rm_f(ac_file)
    generate_nginx_configs
    generate_nginx_admin_configs
    return true
  end


  def last?
    self.class.count == 1
  end

  def concepts_for_option
    @concepts_for_option ||= root_concepts.preload_children.map(&:descendants).flatten(1)
      .map { |c| [c.tree_name, c.id] }
  end

  def public_concepts_for_option
    @public_concepts_for_option ||= public_root_concepts.preload_public_children.map(&:public_descendants).flatten(1)
      .map { |c| [c.tree_name, c.id] }
  end

  def users
    Sys::User.in_site(self)
  end

  def managers
    users.where(auth_no: 5).order(:account)
  end

  def users_for_option
    @users_for_option ||=
      users.where(state: 'enabled').order(:id)
           .map { |u| [u.name_with_account, u.id] }
  end

  def groups_for_option
    @groups_for_option ||=
      Sys::Group.in_site(self).where(level_no: 2)
                .flat_map { |g| g.descendants_in_site(self) }
                .map { |g| [g.tree_name(depth: -1), g.id] }
  end

  def groups_for_option_with_root
    @groups_for_option ||=
      Sys::Group.roots.in_site(self)
                .flat_map { |g| g.descendants_in_site(self) }
                .map { |g| [g.tree_name, g.id] }
  end

  def og_type_text
    OGP_TYPE_OPTIONS.detect{|o| o.last == self.og_type }.try(:first).to_s
  end

  def smart_phone_publication_text
    SMART_PHONE_PUBLICATION_OPTIONS.detect{|o| o.last == smart_phone_publication }.try(:first).to_s
  end

  def spp_target_text
    SPP_TARGET_OPTIONS.detect{|o| o.last == spp_target }.try(:first).to_s
  end

  def publish_for_smart_phone?
    smart_phone_publication == 'yes'
  end

  def spp_all?
    spp_target == 'all'
  end

  def spp_only_top?
    spp_target == 'only_top'
  end

  protected

  def fix_full_uri
    [:full_uri, :mobile_full_uri, :admin_full_uri].each do |column|
      self[column] += '/' if self[column].present? && self[column][-1] != '/'
    end
  end

  def block_last_deletion
    raise "Last site can't be deleted." if self.last?
  end

  private

  def set_defaults
    self.smart_phone_publication ||= SMART_PHONE_PUBLICATION_OPTIONS.first.last if self.has_attribute?(:smart_phone_publication)
    self.spp_target ||= SPP_TARGET_OPTIONS.first.last if self.has_attribute?(:spp_target)
  end

  def generate_files
    FileUtils.mkdir_p public_path
    FileUtils.mkdir_p "#{public_path}/_dynamic"
    FileUtils.mkdir_p "#{public_path}/_themes"
    FileUtils.mkdir_p config_path
    FileUtils.touch "#{config_path}/rewrite.conf"
  end

  def destroy_files
    FileUtils.rm_rf root_path
  end

  def copy_common_directory
    src_path = Rails.public_path.join("_common")
    dst_path = Rails.root.join("#{public_path}/_common")
    if ::File.exists?(src_path) && !::File.exists?(dst_path)
      ::FileUtils.cp_r(src_path, dst_path)
    end
  end

  def force_copy_common_directory
    src_path = Rails.public_path.join("_common")
    dst_path = Rails.root.join("#{public_path}/_common")
    if ::File.exists?(src_path)
      FileUtils.mkdir_p(dst_path) unless FileTest.exist?(dst_path)
      ::FileUtils.cp_r(Dir.glob(%Q(#{src_path}/*)), dst_path)
    end
  end

  def make_concept
    concepts.create(name: name, parent_id: 0, state: 'public', level_no: 1, sort_no: 1)
  end

  def make_node
    if (node = root_node)
      node.update_attribute(:title, name) unless node.title == name
      return
    end

    node = nodes.create(concept: concepts.first, state: 'public', published_at: Time.current,
                        parent_id: 0, route_id: 0, model: 'Cms::Directory',
                        directory: 1, name: '/', title: name)
    top = nodes.create(concept: concepts.first, state: 'public', published_at: Time.current,
                       parent_id: node.id, route_id: node.id, model: 'Cms::Page',
                       directory: 0, name: 'index.html', title: name, body: 'ZOMEKI')

    update_column(:node_id, node.id)
  end

  def make_site_belonging
    if in_root_group_id == '0'
      group = Sys::Group.new(state: 'enabled', parent_id: 0, level_no: 1, code: 'root', name: name, name_en: 'top', ldap: 0)
      group.sites << self
      group.save(validate: false)
    else
      site_belongings.create(group_id: in_root_group_id)
    end
  end
end
