class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes, id: :uuid do |t|
      t.string :title, null: false
      t.string :password_digest, null: false
    end
  end
end
