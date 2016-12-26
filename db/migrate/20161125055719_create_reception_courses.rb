class CreateReceptionCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :reception_courses do |t|
      t.references  :content, index: true
      t.string      :state
      t.string      :name
      t.string      :title
      t.text        :subtitle
      t.text        :body
      t.text        :remark
      t.text        :description
      t.integer     :capacity
      t.integer     :fee
      t.text        :fee_remark
      t.integer     :sort_no
      t.timestamps
    end
  end
end
