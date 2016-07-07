class AddInquirableToCmsInquiries < ActiveRecord::Migration
  KLASSES = [
    GpArticle::Doc,
  ]

  def up
    add_reference :cms_inquiries, :inquirable, index: true, polymorphic: true
    KLASSES.each do |klass|
      klass.find_each {|o| o.inquiries = Cms::Inquiry.where(parent_unid: o.unid) }
    end
  end

  def down
    remove_reference :cms_inquiries, :inquirable, index: true, polymorphic: true
  end
end
