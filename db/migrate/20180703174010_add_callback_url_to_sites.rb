class AddCallbackUrlToSites < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :callback_url, :string
  end
end
