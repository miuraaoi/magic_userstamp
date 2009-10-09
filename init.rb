require 'userstamp'
ActionController::Base.send(:include, Userstamp::Controller) if defined?(ActionController)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Userstamp::MigrationHelper)
if defined?(ActiveRecord)
  ActiveRecord::Base.module_eval do 
    include Userstamp::Stampable
    include Userstamp::Stamper
    include Userstamp::MagicColumns # mest be included after Userstamp::Stampable
  end
end
