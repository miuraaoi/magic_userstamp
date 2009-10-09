# -*- coding: utf-8 -*-
module Userstamp
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
