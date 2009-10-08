# -*- coding: utf-8 -*-
require 'userstamp'

module Userstamp
  # Determines what default columns to use for recording the current stamper.
  # By default this is set to false, so the plug-in will use columns named
  # <tt>creator_id</tt>, <tt>updater_id</tt>, and <tt>deleter_id</tt>.
  #
  # To turn compatibility mode on, place the following line in your environment.rb
  # file:
  #
  #   Userstamp.compatibility_mode = true
  #
  # This will cause the plug-in to use columns named <tt>created_by</tt>,
  # <tt>updated_by</tt>, and <tt>deleted_by</tt>.
  mattr_accessor :compatibility_mode
  @@compatibility_mode = false

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
        raise UserstampError, "Invalid event name '#{event_name.inspect}'. Event name must be one of #{valid_names.inspect}"
      end
    end
  end

  Event.create(:create , :creator, 'created_by')
  Event.create(:update , :updater, 'updated_by', :actual_hook => :before_save)
  Event.create(:destroy, :deleter, 'deleted_by', :after_callback => "save")

  class UserstampError < StandardError
  end

  # Extends the stamping functionality of ActiveRecord by automatically recording the model
  # responsible for creating, updating, and deleting the current object. See the Stamper
  # and Userstamp modules for further documentation on how the entire process works.
  module Stampable
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
      base.class_eval do
        include InstanceMethods

        # Should ActiveRecord record userstamps? Defaults to true.
        class_inheritable_accessor  :record_userstamp
        self.record_userstamp = true

        # Which class is responsible for stamping? Defaults to :user.
        class_inheritable_accessor  :stamper_class_name

        # self.stampable
      end
    end

    module ClassMethods
      # This method is automatically called on for all classes that inherit from
      # ActiveRecord, but if you need to customize how the plug-in functions, this is the
      # method to use. Here's an example:
      #
      #   class Post < ActiveRecord::Base
      #     stampable :stamper_class_name => :person,
      #               :creator_attribute  => :create_user,
      #               :updater_attribute  => :update_user,
      #               :deleter_attribute  => :delete_user
      #   end
      #
      # The method will automatically setup all the associations, and create <tt>before_save</tt>
      # and <tt>before_create</tt> filters for doing the stamping.
      def stampable(options = {})
        reader_name = Userstamp.compatibility_mode ? :default_attribute_compatible : :default_attribute
        options  = {
          :stamper_class_name => "User",
          :creator_attribute  => Event[:create ].send(reader_name),
          :updater_attribute  => Event[:update ].send(reader_name),
          :deleter_attribute  => Event[:destroy].send(reader_name)
        }.update(options || {})

        stamper_class_name = options[:stamper_class_name].to_s
        stamper_class_name = stamper_class_name.camelize unless stamper_class_name =~ /^[A-Z]/

        self.stamper_class_name = stamper_class_name

        with_options(:stamper_class_name => self.stamper_class_name) do |s|
          s.stampable_on(:create , :attribute => options[:creator_attribute])
          s.stampable_on(:update , :attribute => options[:updater_attribute])
          s.stampable_on(:destroy, :attribute => options[:deleter_attribute]) if defined?(Caboose::Acts::Paranoid)
        end
      end

      def stampable_on(event_name, options = {})
        event = Event[event_name]
        reader_name = Userstamp.compatibility_mode ? :default_attribute_compatible : :default_attribute
        options = {
          :stamper_name => event.actor,
          :stamper_class_name => "User",
          # :stamper_attribute => nil
          :attribute => event.send(reader_name),
        }.update(options || {})

        belongs_to_class_name = options[:stamper_class_name].to_s
        belongs_to_class_name = belongs_to_class_name.singularize.camelize unless belongs_to_class_name =~ /^[A-Z]/
        callback_method_name = "set_#{options[:attribute]}_on_#{event.name}"

        method_definitions = <<-"EOS"
          belongs_to(:#{options[:stamper_name]},
            :class_name => '#{belongs_to_class_name}',
            :foreign_key => '#{options[:attribute].to_s}')

          #{event.actual_hook} :#{callback_method_name}

          def #{callback_method_name}
            return unless self.record_userstamp
            send("#{options[:attribute]}=", self.class.stamper_class.stamper) if has_stamper?
            #{event.after_callback}
          end
        EOS
        module_eval(method_definitions, __FILE__, __LINE__)
      end

      # Temporarily allows you to turn stamping off. For example:
      #
      #   Post.without_stamps do
      #     post = Post.find(params[:id])
      #     post.update_attributes(params[:post])
      #     post.save
      #   end
      def without_stamps
        original_value = self.record_userstamp
        self.record_userstamp = false
        begin
          yield
        ensure
          self.record_userstamp = original_value
        end
      end

      def stamper_class #:nodoc:
        @stamper_class ||= stamper_class_name.to_s.constantize
      end
    end

    module InstanceMethods #:nodoc:
      private
        def has_stamper?
          !!(self.class.stamper_class && self.class.stamper_class.stamper)
        end

      #end private
    end
  end
end
