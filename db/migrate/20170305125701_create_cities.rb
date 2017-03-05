class CreateCities < ActiveRecord::Migration[5.0]
  def up
    create_table :cities do |t|
    	t.string "city", :limit=> 200
      t.timestamps
    end
    add_index("cities", "city")
  end

  def down
  	drop_table :cities
  end
end
