module Userstamp
  autoload :Controller, 'userstamp/controller'
  autoload :Event, 'userstamp/event'
  autoload :MigrationHelper, 'userstamp/migration_helper'
  autoload :Stampable, 'userstamp/stampable'
  autoload :Stamper, 'userstamp/stamper'

  class UserstampError < StandardError
  end
end
