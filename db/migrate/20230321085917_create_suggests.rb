class CreateSuggests < ActiveRecord::Migration
  def change
    create_table :suggests do |t|
      t.string :sector
      t.string :size
      t.string :title
      t.text :description
      t.references :tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
