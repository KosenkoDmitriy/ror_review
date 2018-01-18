class AddRequestIdToResponse < ActiveRecord::Migration[5.1]
  def change
    add_reference :responses, :request, foreign_key: true
  end
end
