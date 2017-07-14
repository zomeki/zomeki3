class Tool::ConvertSetting < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  GROUP_RELATION_OPTIONS = [['グループIDと照合', 0], ['グループ名と照合', 1], ['グループ名英語表記と照合', 2]]

  validates_uniqueness_of :site_url
  validates_presence_of :site_url, :title_tag, :body_tag

  def title_xpath
    Tool::Convert::Common.convert_to_xpath(title_tag)
  end

  def body_xpath
    Tool::Convert::Common.convert_to_xpath(body_tag)
  end

  def updated_at_xpath
    Tool::Convert::Common.convert_to_xpath(updated_at_tag)
  end

  def published_at_xpath
    Tool::Convert::Common.convert_to_xpath(published_at_tag)
  end

  def creator_group_xpath
    Tool::Convert::Common.convert_to_xpath(creator_group_tag)
  end

  def category_xpath
    Tool::Convert::Common.convert_to_xpath(category_tag)
  end

  def creator_group_relations_map
    @creator_group_relations_map ||= make_map(creator_group_relations)
  end

  def category_relations_map
    @category_lations_map ||= make_map(category_relations)
  end

  private

  def make_map(text)
    hash = {}
    text.to_s.split(/\r\n|\n|\r/).each do |l|
      l =~ /^(.*?)>(.*?)$/
      break if $1 == nil || $2 == nil
      bef = $1
      aft = $2
      hash[bef] = aft
    end
    hash
  end
end
