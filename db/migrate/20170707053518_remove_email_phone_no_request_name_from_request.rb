class RemoveEmailPhoneNoRequestNameFromRequest < ActiveRecord::Migration[5.1]
  def change
    remove_column :requests, :email, :string
    remove_column :requests, :phone_no, :string
    remove_column :requests, :request_name, :string
  end
end
