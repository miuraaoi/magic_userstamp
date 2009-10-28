# -*- coding: utf-8 -*-
require 'magic_userstamp'

module MagicUserstamp

  class Event 
    attr_reader :name, :actor, :actual_hook, :after_callback
    attr_reader:default_attribute, :default_attribute_compatible

    def initialize(name, actor, default_attribute_compatible, options = nil)
      @name, @actor = name.to_s, actor.to_s
      @default_attribute = "#{@actor}_id"
      @default_attribute_compatible = default_attribute_compatible
      options = {
        :actual_hook => "before_#{@name.to_s}"
      }.update(options || {})
      @actual_hook = options[:actual_hook]
      @after_callback = options[:after_callback]
    end
    
    class << self
      def create(name, actor, default_attribute_compatible, options = nil, &block)
        result = self.new(name, actor, default_attribute_compatible, options, &block)
        @name_hash ||= HashWithIndifferentAccess.new
        @name_hash[name] = result
        @instances ||= []
        @instances << result
        result
      end

      def [](event_name)
        raise_unless_valid_name(event_name)
        @name_hash[event_name]
      end

      def each(&block)
        return unless block
        (@instances || []).each(&block)
      end

      def actor_name(event_name)
        self[event_name].actor
      end

      def valid_names
        (@instances || []).map(&:name)
      end
      
      def valid_name?(event_name)
        valid_names.include?(event_name.to_s)
      end

      def raise_unless_valid_name(event_name)
        return if valid_name?(event_name)
        raise MagicUserstampError, "Invalid event name '#{event_name.inspect}'. Event name must be one of #{valid_names.inspect}"
      end
    end
  end

  Event.create(:create , :creator, 'created_by')
  Event.create(:update , :updater, 'updated_by', :actual_hook => :before_save)
  Event.create(:destroy, :deleter, 'deleted_by') #, :after_callback => "save")
end
