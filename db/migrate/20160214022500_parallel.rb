class Parallel < ActiveRecord::Migration
    def change
        add_column  :condo_uploads, :part_list, :string
        add_column  :condo_uploads, :part_data, :text
        remove_column :condo_uploads, :custom_params
    end
end
