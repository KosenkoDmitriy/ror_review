class RemoveTextToTemplates < ActiveRecord::Migration[5.1]
  def change
    remove_column :templates, :text, :text
  end
end
