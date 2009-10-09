# -*- coding: utf-8 -*-
require 'userstamp'

module Userstamp
  
  class Config

    class << self
      def setup(&block)
        @config = Config.new
      end

      def clear
        @config = nil
      end
    end

    attr_reader :patterns
    attr_accessor :with_destroy

    def initialize
      @patterns = []
      @with_destroy = defined?(Caboose::Acts::Paranoid)
    end
    
    def pattern_for(klass, column_name)
      patterns.detect{|pattern| pattern.stampable?(klass, column_name)}
    end

    def on(event_name, column_name, options = nil)
      result = Pattern.new(event_name, column_name, options)
      patterns << result
      result
    end

    def defaults(options = nil)
      on(:create , :creator_id, options)
      on(:update , :updater_id, options)
      on(:destroy, :deleter_id, options) if with_destroy
    end

    def compatibles(options = nil)
      on(:create , :created_by, options)
      on(:update , :updated_by, options)
      on(:destroy, :deleted_by, options) if with_destroy
    end

    class Pattern
      attr_reader :event_name, :column_name, :stampable_class_names
      attr_reader :stamper_class_name, :stamper_attr_name

      def initialize(event_name, column_name, options = nil)
        @event_name = event_name
        @column_name = column_name
        options = {
          :stampable_class_names => nil,
          :stamper_class_name => 'User',
          :stamper_attr_name => nil # sholuld not be only 'id' but PK column name
        }.update(options || {})
        @stampable_class_names = options[:stampable_class_names]
        @stamper_class_name = options[:stamper_class_name]
        @stamper_attr_name = options[:stamper_attr_name]
      end
      
      def stampable?(klass, column_name)
        (stampable_class_names.nil? ? true : stampable_class_names.include?(klass.name)) &&
          (column_name.to_s == self.column_name.to_s)
      end

    end

  end
end
