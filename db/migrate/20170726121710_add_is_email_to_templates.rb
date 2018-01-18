class AddIsEmailToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :templates, :is_email, :boolean
  end
end
