class AddIndexForSiteUrl < ActiveRecord::Migration[5.2]
  def change
    add_index :sites, :url
  end
end
