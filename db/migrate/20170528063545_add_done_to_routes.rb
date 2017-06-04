class AddDoneToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :done, :boolean, default: false
  end
end
