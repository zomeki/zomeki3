class AdBanner::Banner < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no, :id) }

  attribute :sort_no, :integer, default: 10

  enum_ish :state, [:public, :closed], default: :public
  enum_ish :target, [:_self, :_blank], default: :_self

  # Content
  belongs_to :content, class_name: 'AdBanner::Content::Banner', required: true

  belongs_to :group, class_name: 'AdBanner::Group'
  has_many :clicks, foreign_key: :banner_id, class_name: 'AdBanner::Click', dependent: :destroy
  has_many :publishers, class_name: 'Sys::Publisher', dependent: :destroy, as: :publishable

  validates :state, presence: true
  validates :advertiser_name, presence: true
  validates :url, presence: true
  validates :token, uniqueness: { scope: :content_id } 

  before_validation :set_token

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true)

  scope :published, -> {
    now = Time.now
    where(arel_table[:state].eq('public')
          .and(arel_table[:published_at].eq(nil).or(arel_table[:published_at].lteq(now))
          .and(arel_table[:closed_at].eq(nil).or(arel_table[:closed_at].gt(now)))))
  }
  scope :closed, -> {
    now = Time.now
    where(arel_table[:state].eq('closed')
          .or(arel_table[:published_at].gt(now))
          .or(arel_table[:closed_at].lteq(now)))
  }

  def image_uri
    return '' unless content.public_node
    "#{content.public_node.public_uri}#{name}"
  end

  def image_path
    return '' unless content.public_node
    "#{content.public_node.public_path}#{name}"
  end

  def image_smart_phone_path
    return '' unless content.public_node
    "#{content.public_node.public_smart_phone_path}#{name}"
  end

  def link_uri
    return '' unless content.public_node
    "#{content.public_node.public_uri}#{token}"
  end

  def published?
    now = Time.now
    (state == 'public') && (published_at.nil? || published_at <= now) && (closed_at.nil? || closed_at > now)
  end

  def closed?
    !published?
  end

  private

  def set_token
    self.token ||= Util::String::Token.generate_unique_token(self.class, :token)
  end

  # Override Sys::Model::Base::File#duplicated?
  def duplicated?
    banners = self.class.arel_table
    not self.class.where(content_id: self.content_id, name: self.name).where(banners[:id].not_eq(self.id)).empty?
  end

  concerning :Publication do
    included do
      define_model_callbacks :publish_files, :close_files
      after_publish_files Cms::FileTransferCallbacks.new([:image_path, :image_smart_phone_path], recursive: true)
      after_close_files Cms::FileTransferCallbacks.new([:image_path, :image_smart_phone_path], recursive: true)
    end

    def publish_images
      run_callbacks :publish_files do
        paths = [[image_path, nil]]
        paths << [image_smart_phone_path, :smart_phone] if content.site.publish_for_smart_phone?
        paths.each do |path, dep|
          pub = Sys::Publisher.where(publishable: self, dependent: dep.to_s).first_or_initialize
          pub.publish_file_with_digest(upload_path, path)
        end
      end
    end

    def close_images
      run_callbacks :close_files do
        publishers.destroy_all
        paths = [image_path]
        paths << image_smart_phone_path if content.site.publish_for_smart_phone?
        paths.each do |path|
          FileUtils.rm path if ::File.exist?(path)
          FileUtils.rmdir ::File.dirname(path)
        end
      end
    end
  end
end
