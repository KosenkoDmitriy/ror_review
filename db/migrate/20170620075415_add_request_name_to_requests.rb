class AddRequestNameToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :request_name, :string
  end
end
