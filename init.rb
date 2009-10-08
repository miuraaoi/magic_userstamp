require 'userstamp'
ActionController::Base.send(:include, Userstamp::Controller) if defined?(ActionController)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Userstamp::MigrationHelper)
ActiveRecord::Base.send(:include, Userstamp::Stampable) if defined?(ActiveRecord)
ActiveRecord::Base.send(:include, Userstamp::Stamper) if defined?(ActiveRecord)
