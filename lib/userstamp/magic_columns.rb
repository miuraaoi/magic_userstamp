# -*- coding: utf-8 -*-
require 'userstamp'

module Userstamp

  module MagicColumns
    def self.included(mod)
      mod.extend(ClassMethods)
      mod.instance_eval do
        alias :columns_without_userstamp :columns
        alias :columns :columns_with_userstamp
      end
    end

    module ClassMethods
      def columns_with_userstamp
        result = columns_without_userstamp
        unless @userstamp_configurated
          setup_userstamp
          @userstamp_configurated = true
        end
        result
      end

      def setup_userstamp
        
      end

    end

    
  end

end
