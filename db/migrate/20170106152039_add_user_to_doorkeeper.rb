class AddUserToDoorkeeper < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :oauth_access_grants, :users, column: :resource_owner_id, on_delete: :cascade
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id, on_delete: :cascade
  end
end
