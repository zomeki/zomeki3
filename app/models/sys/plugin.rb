class Sys::Plugin < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  GITHUB_USER = 'zomeki'
  GITHUB_TOPIC = 'zomeki3-plugin'

  enum_ish :state, [:enabled, :disabled], predicate: true

  validates :name, presence: true, uniqueness: true,
                   format: { with: %r|\A[^/]+/[^/]+\z| }
  validates :version, presence: true,
                      format: { with: %r|\A[^/]+/.+\z| }
  validates :title, presence: true

  def gem_name
    name.split('/').last
  end

  def engine
    Rails.application.config.x.engines.detect { |engine|
      engine.root.to_s.split('/').last.gsub(/-[0-9a-z]{12}$/, '') == gem_name
    }
  end

  def source
    version.split('/').first
  end

  def source_version
    version.split('/').last
  end

  class << self
    def search_repos
      require 'octokit'
      result = Octokit.search_repositories("user:#{GITHUB_USER} topic:#{GITHUB_TOPIC}")
      repos = result[:items].map { |item| item.to_h.slice(:full_name, :description) }
      repos.uniq
    end

    def version_options(name)
      require 'octokit'
      tags = Octokit.tags(name)
      branches = Octokit.branches(name)
      tags.map { |tag| "tag/#{tag[:name]}" } + branches.map { |branch| "branch/#{branch[:name]}" }
    rescue => e
      error_log e
      []
    end

    def title_options(name)
      require 'octokit'
      Octokit.repository(name)[:description]
    rescue => e
      error_log e
      ''
    end
  end
end
