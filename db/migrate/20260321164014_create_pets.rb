class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :species
      t.string :breed
      t.integer :age
      t.text :notes

      t.timestamps
    end
  end
end
