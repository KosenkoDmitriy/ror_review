class AddClientIdToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_reference :templates, :client, foreign_key: true
  end
end
