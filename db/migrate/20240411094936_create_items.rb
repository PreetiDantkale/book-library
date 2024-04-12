class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :title
      t.string :isbn
      t.string :genre
      t.string :item_type

      t.timestamps
    end
  end
end
