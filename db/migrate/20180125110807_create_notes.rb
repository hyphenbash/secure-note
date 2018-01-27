class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.uuid :uuid, null: false
      t.string :title, null: false
      t.string :password_digest, null: false
      t.binary :body_text_key, null: false
      t.binary :body_text_iv, null: false
    end
  end
end
