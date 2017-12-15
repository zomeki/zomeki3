class Sys::Plugin < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  GITHUB_USER = 'zomeki'
  GITHUB_TOPIC = 'zomeki3-plugin'
  STATE_OPTIONS = [['有効','enabled'], ['無効','disabled']]

  validates :name, presence: true, uniqueness: true,
                   format: { with: %r|\A[^/]+/[^/]+\z| }
  validates :version, presence: true,
                      format: { with: %r|\A[^/]+/.+\z| }
  validates :title, presence: true

  scope :search_with_params, ->(params = {}) {
    all
  }

  scope :enabled_contents, ->{
    where(state: 'enabled').where(use_as_content: true)
  }

  def gem_name
    name.split('/').last
  end

  def engine_class_name
    gem_name.gsub('-', '/').classify + '::Engine'
  end

  def engine_route
    if use_as_content?
      "/"
    else
      route = name.split('/').last
      "/#{ZomekiCMS::ADMIN_URL_PREFIX}/plugins/#{route}"
    end
  end

  def source
    version.split('/').first
  end

  def source_version
    version.split('/').last
  end

  def state_enabled?
    state == 'enabled'
  end

  def state_label
    STATE_OPTIONS.rassoc(state).try(:first)
  end

  class << self
    def search_repos
      result = Octokit.search_repositories("user:#{GITHUB_USER} topic:#{GITHUB_TOPIC}")
      repos = result[:items].map { |item| item.to_h.slice(:full_name, :description) }
      repos.uniq
    end

    def version_options(name)
      tags = Octokit.tags(name)
      branches = Octokit.branches(name)
      tags.map { |tag| "tag/#{tag[:name]}" } + branches.map { |branch| "branch/#{branch[:name]}" }
    rescue => e
      error_log e
      []
    end

    def title_options(name)
      Octokit.repository(name)[:description]
    rescue => e
      error_log e
      ''
    end
  end
end
