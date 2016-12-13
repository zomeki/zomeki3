class CreateCmsLinks < ActiveRecord::Migration[5.0]
  def up
    create_table :cms_links do |t|
      t.integer  :content_id
      t.string   :linkable_type
      t.integer  :linkable_id
      t.string   :body
      t.string   :url
      t.timestamps
    end
    GpArticle::Link.all.each do |l|
      Cms::Link.create({
        content_id: l.doc.try(:content_id),
        linkable_type: 'GpArticle::Doc',
        linkable_id:   l.doc_id,
        body: l.body,
        url:  l.url
      })
    end
    Cms::Node::Page.public_state.each do |p|
      next unless lib = p.links_in_body
      lib.each do |link|
       p.links.create(body: link[:body], url: link[:url], content_id: p.content_id)
      end
    end
  end

  def down
    drop_table :cms_links
  end
end
