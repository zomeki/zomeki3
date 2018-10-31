class AddResCreationToPublicBbsThreads < ActiveRecord::Migration[4.2]
  def change
    add_column :public_bbs_threads, :res_creation, :string
  end
end
