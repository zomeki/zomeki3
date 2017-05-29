class Cms::Site < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Page

  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::DataFile
  include Cms::Model::Rel::SiteSetting

  include StateText

  OGP_TYPE_OPTIONS = [['article', 'article'], ['product', 'product'], ['profile', 'profile']]
  SMART_PHONE_LAYOUT_OPTIONS = [['スマートフォンレイアウトを優先', 'smart_phone'], ['PCレイアウトで表示', 'pc']]
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
  belongs_to :root_node, foreign_key: :node_id, class_name: 'Cms::Node'

  # conditional relations
  has_many :root_concepts, -> { where(level_no: 1).order(:sort_no, :name, :id) },
    class_name: 'Cms::Concept'
  has_many :public_root_concepts, -> { where(level_no: 1, state: 'public').order(:sort_no, :name, :id) },
    class_name: 'Cms::Concept'
  has_many :public_sitemap_nodes, -> { where(state: 'public', model: 'Cms::Sitemap').order(:name) },
    class_name: 'Cms::Node'
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

  before_validation :fix_full_uri
  before_destroy :block_last_deletion

  after_save :generate_files
  after_destroy :destroy_files

  after_create :make_concept
  after_create :make_site_belonging
  after_save :make_node
  after_save :copy_common_directory

  scope :matches_to_domain, ->(domain) {
    where([
      arel_table[:full_uri].matches("http://#{domain}%"),
      arel_table[:full_uri].matches("https://#{domain}%"),
      arel_table[:mobile_full_uri].matches("http://#{domain}%"),
      arel_table[:mobile_full_uri].matches("https://#{domain}%"),
      arel_table[:admin_full_uri].matches("http://#{domain}%"),
      arel_table[:admin_full_uri].matches("https://#{domain}%")
    ].reduce(:or))
  }

  def creatable?
    return false unless Core.user.has_auth?(:manager)
    Core.user.root? || Core.user.site_creatable?
  end

  def readable?
    return false unless Core.user.has_auth?(:manager)
    Core.user.root? || Core.user.sites.include?(self)
  end

  def editable?
    readable?
  end

  def deletable?
    readable?
  end

  def states
    [['公開','public']]
  end

  def root_path
    Rails.root.join("sites/#{format('%04d', id)}").to_s
  end

  def public_path
    "#{root_path}/public"
  end

  def public_themes_path
    "#{root_path}/public/_themes"
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
    url  = Sys::Setting.common_ssl_uri
    url += "_ssl/#{format('%04d', id)}/"
    return url
  end

  def main_admin_uri
    admin_full_uri.presence || full_uri
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
    users.where(auth_no: 5).where.not(id: Sys::User::ROOT_ID).order(:account)
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

  def groups_for_option_except(group)
    Sys::Group.roots.in_site(self).where.not(id: group.id)
              .flat_map { |g| g.descendants_in_site(self) { |rel| rel.where.not(id: group.id) } }
              .map { |g| [g.tree_name, g.id] }
  end

  def og_type_text
    OGP_TYPE_OPTIONS.detect{|o| o.last == self.og_type }.try(:first).to_s
  end

  def smart_phone_layout_text
    SMART_PHONE_LAYOUT_OPTIONS.rassoc(smart_phone_layout).try(:first).to_s
  end

  def smart_phone_layout_same_as_pc?
    smart_phone_layout == 'pc'
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

  def apache_config_path
    "config/apache/virtual_hosts/site_#{'%04d' % id}.conf"
  end

  def apache_admin_config_path
    "config/apache/admin_virtual_hosts/site_#{'%04d' % id}.conf"
  end

  def nginx_config_path
    "config/nginx/servers/site_#{'%04d' % id}.conf"
  end

  def nginx_admin_config_path
    "config/nginx/admin_servers/site_#{'%04d' % id}.conf"
  end

  def basic_auth_htaccess_path
    "#{::File.dirname(public_path)}/.htaccess"
  end

  def basic_auth_htpasswd_path
    "#{::File.dirname(public_path)}/.htpasswd"
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
    ::File.exists?(basic_auth_htpasswd_path)
  end

  def system_basic_auth_enabled?
    ::File.exists?("#{basic_auth_htpasswd_path}_system")
  end

  def directory_basic_auth_enabled?(directory)
    ::File.exists?("#{basic_auth_htpasswd_path}_#{directory}")
  end

  def basic_auth_state_enabled?
    settings.where(name: 'basic_auth_state', value: 'enabled').exists?
  end

  def enable_basic_auth
    self.load_site_settings
    self.in_setting_site_basic_auth_state = 'enabled'
    self.save
  end

  def disable_basic_auth
    self.load_site_settings
    self.in_setting_site_basic_auth_state = 'disabled'
    self.save
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
    self.smart_phone_layout ||= SMART_PHONE_LAYOUT_OPTIONS.first.last if self.has_attribute?(:smart_phone_layout)
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
                       directory: 0, name: 'index.html', title: name, body: Core.title)

    update_column(:node_id, node.id)
  end

  def make_site_belonging
    if in_root_group_id == '0'
      group = Sys::Group.new(state: 'enabled', parent_id: 0, level_no: 1, code: 'root', name: name, name_en: 'top', ldap: 0)
      group.sites << self
      group.save
    else
      site_belongings.create(group_id: in_root_group_id)
    end
  end

  class << self
    def all_with_full_uri(full_uri)
      uri = Addressable::URI.parse(full_uri)
      matches_to_domain(uri.host).order(:id)
    end

    def reload_servers
      FileUtils.touch reload_servers_text_path
    end

    def reload_servers_text_path
      Rails.root.join('tmp/reload_servers.txt')
    end
  end
end
