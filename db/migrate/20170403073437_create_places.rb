class CreatePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :places do |t|
    	t.string :origin
    	t.string :destination
    	t.integer :distance	
      t.timestamps
    end
  end
end
