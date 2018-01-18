class AddEmailSubjectToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :templates, :email_subject, :string
  end
end
