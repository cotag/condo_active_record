require 'condo'
require 'condo_active_record/engine'
require 'condo/backend/active_record'

#::Condo::Application.backend = Condo::Backend::ActiveRecord
silence_warnings { ::Condo.const_set(:Store, Condo::Backend::ActiveRecord) }
