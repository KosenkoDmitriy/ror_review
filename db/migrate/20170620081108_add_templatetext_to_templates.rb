class AddTemplatetextToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :templates, :template_text, :string
  end
end
