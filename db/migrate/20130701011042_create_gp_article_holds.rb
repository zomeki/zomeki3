class CreateGpArticleHolds < ActiveRecord::Migration[4.2]
  def change
    create_table :gp_article_holds do |t|
      t.belongs_to :holdable, polymorphic: true

      t.references :user

      t.timestamps
    end
  end
end
