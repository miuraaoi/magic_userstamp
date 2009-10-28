# -*- coding: utf-8 -*-
require 'magic_userstamp'
# コントローラへは自身でincludeしてください。
# ActionController::Base.send(:include, MagicUserstamp::Controller) if defined?(ActionController)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, MagicUserstamp::MigrationHelper)
if defined?(ActiveRecord)
  ActiveRecord::Base.module_eval do
    include MagicUserstamp
  end
end
