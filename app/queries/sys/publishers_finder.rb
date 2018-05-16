class Sys::PublishersFinder < ApplicationFinder
  def initialize(publishers)
    @publishers = publishers
  end

  def search(criteria)
    criteria ||= {}

    if criteria[:path].present?
      @publishers = @publishers.search_with_text(:path, criteria[:path])
    end

    case criteria[:dependent]
    when 'ruby'
      @publishers = @publishers.with_ruby_dependent
    when 'talk'
      @publishers = @publishers.with_talk_dependent
    when 'smartphone'
      @publishers = @publishers.with_smartphone_dependent
    end

    @publishers
  end

  private

  def arel_table
    @users.arel_table
  end
end
