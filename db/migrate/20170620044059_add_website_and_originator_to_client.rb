class AddWebsiteAndOriginatorToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :website, :string
    add_column :clients, :originator, :text
  end
end
