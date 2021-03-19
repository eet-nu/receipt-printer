class CreateSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.string :secret
      t.string :printer_id

      t.timestamps
    end
  end
end
