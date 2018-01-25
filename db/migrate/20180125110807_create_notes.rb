class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes, id: :uuid do |t|
      t.string :title
      t.string :password_digest
    end
  end
end
