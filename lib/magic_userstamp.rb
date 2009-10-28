# -*- coding: utf-8 -*-
module MagicUserstamp
  def self.included(mod)
    if mod <= ::ActiveRecord::Base
      mod.module_eval do
        include MagicUserstamp::Stampable
        include MagicUserstamp::Stamper
        include MagicUserstamp::MagicColumns # mest be included after Userstamp::Stampable
      end
    end
  end

  autoload :Config, 'magic_userstamp/config'
  autoload :Controller, 'magic_userstamp/controller'
  autoload :Event, 'magic_userstamp/event'
  autoload :MagicColumns, 'magic_userstamp/magic_columns'
  autoload :MigrationHelper, 'magic_userstamp/migration_helper'
  autoload :Stampable, 'magic_userstamp/stampable'
  autoload :Stamper, 'magic_userstamp/stamper'

  class MagicUserstampError < StandardError
  end

  def self.config
    Config.instance
  end
end
