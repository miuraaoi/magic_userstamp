# -*- coding: utf-8 -*-
module Userstamp
  def self.included(mod)
    if mod <= ::ActiveRecord::Base
      mod.module_eval do
        include Userstamp::Stampable
        include Userstamp::Stamper
        include Userstamp::MagicColumns # mest be included after Userstamp::Stampable
      end
    end
  end

  autoload :Config, 'userstamp/config'
  autoload :Controller, 'userstamp/controller'
  autoload :Event, 'userstamp/event'
  autoload :MagicColumns, 'userstamp/magic_columns'
  autoload :MigrationHelper, 'userstamp/migration_helper'
  autoload :Stampable, 'userstamp/stampable'
  autoload :Stamper, 'userstamp/stamper'

  class UserstampError < StandardError
  end

  def self.config
    Config.instance
  end
end
