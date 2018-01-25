class EnableUuidExtension < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto'  # postgres >= 9.4
    enable_extension 'uuid-ossp' # postgres <  9.4
  end
end
