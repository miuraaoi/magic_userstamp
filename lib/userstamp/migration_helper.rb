require 'userstamp'

module Userstamp
  module MigrationHelper
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def userstamps(include_deleted_by = false)
        column(Userstamp.compatibility_mode ? :created_by : :creator_id, :integer)
        column(Userstamp.compatibility_mode ? :updated_by : :updater_id, :integer)
        column(Userstamp.compatibility_mode ? :deleted_by : :deleter_id, :integer) if include_deleted_by
      end
    end
  end
end
