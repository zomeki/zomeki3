class Cms::Site < ActiveRecord::Base
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
  has_many :maintenances, class_name: 'Sys::Maintenance', dependent: :destroy
  has_many :messages, class_name: 'Sys::Message', dependent: :destroy
  has_many :operation_logs, class_name: 'Sys::OperationLog'
  has_many :transferred_files, class_name: 'Sys::TransferredFile'
  has_many :transferable_files, class_name: 'Sys::TransferableFile'
  belongs_to :root_node, foreign_key: :node_id, class_name: 'Cms::Node'

  # conditional relations
  has_many :root_concepts, -> { where(level_no: 1).order(:sort_no, :name, :id) }, class_name: 'Cms::Concept'
  has_many :admin_protocol_settings, class_name: 'Cms::SiteSetting::AdminProtocol'
  has_many :emergency_layout_settings, class_name: 'Cms::SiteSetting::EmergencyLayout'

  validates :state, :name, :full_uri, presence: true
  validates :full_uri, uniqueness: true
  validates :mobile_full_uri, uniqueness: true, if: "mobile_full_uri.present?"
  validate :validate_attributes

  after_initialize :set_defaults

  ## site image
  attr_accessor :site_image, :del_site_image
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
  after_save :generate_nginx_configs
  after_destroy :destroy_nginx_configs

  after_create :make_concept
  after_save :make_node

  def states
    [['公開','public']]
  end

  def root_path
    dir = format('%08d', id).sub(/(..)(..)(..)(..)/, '\\1/\\2/\\3/\\4')
    Rails.root.join("sites/#{dir}")
  end

  def public_path
    dir = format('%08d', id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1')
    "#{Rails.root}/sites/#{dir}/public"
  end

  def public_smart_phone_path
    "#{public_path}/_smartphone"
  end

  def config_path
    dir = format('%08d', id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1')
    "#{Rails.root}/sites/#{dir}/config"
  end

  def rewrite_config_path
    "#{config_path}/rewrite.conf"
  end

  def uri
    return '/' unless full_uri.match(/^[a-z]+:\/\/[^\/]+\//)
    full_uri.sub(/^[a-z]+:\/\/[^\/]+\//, '/')
  end

  def domain
    return '' if full_uri.blank?
    URI.parse(full_uri).host
  end

  def mobile_domain
    return '' if mobile_full_uri.blank?
    URI.parse(mobile_full_uri).host
  end

  def publish_uri
    "#{Core.full_uri}_publish/#{format('%08d', id)}/"
  end

  def full_ssl_uri
    return nil unless Sys::Setting.use_common_ssl?
    url  = Sys::Setting.setting_extra_value(:common_ssl, :common_ssl_uri)
    url += "_ssl/#{format('%08d', id)}/"
    return url
  end

  def has_mobile?
    !mobile_full_uri.blank?
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
    self.where(sites[:full_uri].matches("#{http_base}%")
               .or(sites[:full_uri].matches("#{https_base}%"))
               .or(sites[:mobile_full_uri].matches("#{http_base}%"))
               .or(sites[:mobile_full_uri].matches("#{https_base}%")))
        .order(:id)
  end

  def self.find_by_script_uri(script_uri)
    base = script_uri.gsub(/^([a-z]+:\/\/[^\/]+\/).*/, '\1')
    item = Cms::Site.new.public
    cond = Condition.new do |c|
      c.or :full_uri, 'LIKE', "#{base}%"
      c.or :mobile_full_uri, 'LIKE', "#{base}%"
    end
    item.and cond
    return item.order(:id).first
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
    virtual_hosts.join("site_#{'%08d' % id}.conf").write erb
  end

  def destroy_apache_configs
    conf = Rails.root.join("config/apache/virtual_hosts/site_#{'%08d' % id}.conf")
    return false unless conf.exist?
    conf.delete
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
    servers.join("site_#{'%08d' % id}.conf").write erb
  end

  def destroy_nginx_configs
    conf = Rails.root.join("config/nginx/servers/site_#{'%08d' % id}.conf")
    return false unless conf.exist?
    conf.delete
  end

  def basic_auth_enabled?
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"
    return ::File.exists?(pw_file)
  end

  def enable_basic_auth
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
    basic_auth_users.where(state: 'enabled').each do |user|
      conf += %Q(#{user.name}:#{user.password.crypt(salt)}\n)
    end
    Util::File.put(pw_file, :data => conf)

    return true
  end

  def disable_basic_auth
    ac_file = "#{::File.dirname(public_path)}/.htaccess"
    pw_file = "#{::File.dirname(public_path)}/.htpasswd"
    FileUtils.rm_f(ac_file)
    FileUtils.rm_f(pw_file)

    return true
  end

  def last?
    self.class.count == 1
  end

  def concepts_for_option
    root_concepts.map(&:descendants).flatten(1).map{|c| [c.tree_name, c.id] }
  end

  def users
    Sys::User.in_site(self)
  end

  def groups_for_option
    Sys::Group.root.descendants_in_site(self).drop(1).map{|g| [g.tree_name(depth: -1), g.id] }
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
    self.full_uri += '/' if full_uri.present? && full_uri.to_s[-1] != '/'
  end

  def validate_attributes
    if full_uri.to_s.index('_')
      errors.add :full_uri, 'に「_」は使用できません。'
      return
    end

    begin
      URI.parse(full_uri)
    rescue URI::InvalidURIError => e
      errors.add :full_uri, 'は正しいURLではありません。'
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
    FileUtils.mkdir_p config_path
    FileUtils.touch "#{config_path}/rewrite.conf"
  end

  def destroy_files
    FileUtils.rm_rf root_path
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
end
