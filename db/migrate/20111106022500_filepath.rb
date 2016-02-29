class Filepath < ActiveRecord::Migration
    def up
        add_column        :condo_uploads, :file_path, :text
    end
    
    def down
        remove_column     :condo_uploads, :file_path
    end
end
