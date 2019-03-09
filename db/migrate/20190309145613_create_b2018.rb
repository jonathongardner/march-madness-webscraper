class CreateB2018 < ActiveRecord::Migration[5.2]
  def change
    create_table :b2018s do |t|
      t.bigint :unique_game_number, index: true
    end
  end
end
