module Condo
    module Backend

        #
        # The following data needs to be stored in any backend
        # => provider_namespace (for handling multiple upload controllers, defaults to global)
        # => provider_name      (amazon, rackspace, google, azure etc)
        # => provider_location  (US West (Oregon) Region, Asia Pacific (Singapore) Region etc)
        # => user_id            (the identifier for the current user as a string)
        # => file_name          (the original upload file name)
        # => file_size          (the file size as indicated by the client)
        # => file_id            (some sort of identifying hash provided by the client)
        # => bucket_name        (the name of the users bucket)
        # => object_key         (the path to the object in the bucket)
        # => object_options     (custom options that were applied to this object - public/private etc)
        # => resumable_id       (the id of the chunked upload)
        # => resumable          (true if a resumable upload - must be set)
        # => date_created       (the date the upload was started)
        #
        # => Each backend should have an ID that uniquely identifies an entry - id or upload_id
        #
        #
        #
        # Backends should inherit this class, set themselves as the backend and define the following:
        #
        # Class Methods:
        # => check_exists        ({user_id, upload_id})                            returns nil or an entry where all fields match
        #         check_exists   ({user_id, file_name, file_size, file_id})        so same logic for this
        # => add_entry ({user_id, file_name, file_size, file_id, provider_name, provider_location, bucket_name, object_key})
        #
        #            
        #
        # Instance Methods:
        # => update_entry ({upload_id, resumable_id})
        # => remove_entry (upload_id)
        #
        class ActiveRecord < ::ActiveRecord::Base            
            self.table_name = "#{::ActiveRecord::Base.table_name_prefix}condo_uploads"


            serialize :object_options, JSON
            serialize :part_list, JSON    # example: [1,2,5]
            serialize :part_data, JSON  # example: {1:'abd23',2:'56sdv'}


            # Checks for an exact match in the database given a set of parameters
            def self.check_exists(params)
                params = {}.merge(params)
                params[:user_id] = params[:user_id].to_s if params[:user_id].present?
                params[:id] = params.delete(:upload_id).to_i if params[:upload_id].present?                

                self.where(params).first
            end

            # Adds a new upload entry into the database
            def self.add_entry(params)
                params = {}.merge(params)
                params.delete(:upload_id) if params[:upload_id].present?
                params.delete(:id) if params[:id].present?
                params.delete(:resumable_id) if params[:resumable_id].present?

                self.create!(params)
            end

            def self.all_uploads
                self.all
            end

            # Return a list of Uploads that were last updated before a particular time
            def self.older_than(time)
                self.where('updated_at < :time', time: time)
            end



            # Updates self with the passed in parameters
            def update_entry(params)
                result = self.update_attributes(params)
                raise ActiveResource::ResourceInvalid if result == false
                self
            end

            # Deletes reference to the upload
            def remove_entry
                self.destroy
            end

            # Attribute accessors to comply with the backend spec
            def upload_id
                self[:id]
            end

            def date_created
                self[:created_at]
            end

            # Provide a clean up function that uses the condo strata to delete itself
            # NOTE:: this won't work with completely dynamic providers so is really just here
            #  as a helper if you have pre-defined storage providers
            def cleanup
                options = {}
                options[:namespace] = self.provider_namespace if self.provider_namespace
                options[:location] = self.provider_location if self.provider_location
                residence = ::Condo::Configuration.get_residence(self.provider_name, options)

                if residence
                    residence.destroy(self)
                    self.destroy
                else
                    raise NotImplementedError, 'unable to find static residence'
                end
            end
        end
    end
end
