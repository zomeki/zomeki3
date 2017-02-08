class Sys::Plugin < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  GITHUB_USER = 'zomeki'
  STATE_OPTIONS = [['有効','enabled'], ['無効','disabled']]

  validates :name, presence: true, uniqueness: true,
                   format: { with: %r|\A[^/]+/[^/]+\z| }
  validates :version, presence: true,
                      format: { with: %r|\A[^/]+/.+\z| }
  validates :title, presence: true

  scope :search_with_params, ->(params = {}) {
    all
  }

  def gem_name
    name.split('/').last
  end

  def engine_class_name
    gem_name.gsub('-', '/').classify + '::Engine'
  end

  def engine_route
    route = name.split('/').last
    "/#{ZomekiCMS::ADMIN_URL_PREFIX}/plugins/#{route}"
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
      #repos = Octokit.repositories(GITHUB_USER)
      #repos = repos.map { |repo| repo.to_h.slice(:full_name, :description) }

      result = Octokit.search_repositories('topic:zomeki-plugin')
      repos = result[:items].map { |item| item.to_h.slice(:full_name, :description) }
      repos.uniq
    end

     def version_options(name)
      return [] if name.blank?

      tags = Octokit.tags(name)
      branches = Octokit.branches(name)
      tags.map { |tag| "tag/#{tag[:name]}" } + branches.map { |branch| "branch/#{branch[:name]}" }
    end
  end
end
