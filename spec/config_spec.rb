require File.join(File.dirname(__FILE__), 'spec_helper')

describe MagicUserstamp::Config do

  class Foo
  end

  class Bar
  end

  class Baz
  end


  before(:each) do
    @config = MagicUserstamp::Config.new
  end

  describe "on" do
    it "option's default value" do
      pattern = @config.on(:create, :creator_id)
      pattern.event_name.should == :create
      pattern.column_name.should == :creator_id
      pattern.stampable_class_names.should == nil # means all classes
      pattern.stamper_class_name.should == 'User'
      pattern.stamper_attr_name.should == nil # means PK attr name
      [Foo, Bar, Baz].each do |klass|
        pattern.stampable?(klass, 'creator_id').should == true
        pattern.stampable?(klass, 'updater_id').should == false
        pattern.stampable?(klass, 'deleter_id').should == false
        pattern.stampable?(klass, :creator_id).should == true
        pattern.stampable?(klass, :updater_id).should == false
        pattern.stampable?(klass, :deleter_id).should == false

        @config.pattern_for(klass, 'creator_id').should == pattern
        @config.pattern_for(klass, 'updater_id').should == nil
        @config.pattern_for(klass, 'deleter_id').should == nil
      end
    end
    
    it "full options" do
      pattern = @config.on(:create, :creator_no, 
        :stampable_class_names => %w(Bar Baz),
        :stamper_class_name => 'Admin',
        :stamper_attr_name => 'admin_no'
        )
      pattern.event_name.should == :create
      pattern.column_name.should == :creator_no
      pattern.stampable_class_names.should == ['Bar', 'Baz'] # means all classes
      pattern.stamper_class_name.should == 'Admin'
      pattern.stamper_attr_name.should == 'admin_no' # means PK attr name
      [Bar, Baz].each do |klass|
        pattern.stampable?(klass, 'creator_no').should == true
        pattern.stampable?(klass, 'creator_id').should == false
        pattern.stampable?(klass, 'updater_id').should == false
        pattern.stampable?(klass, 'deleter_id').should == false

        @config.pattern_for(klass, 'creator_no').should == pattern
        @config.pattern_for(klass, 'creator_id').should == nil
        @config.pattern_for(klass, 'updater_id').should == nil
        @config.pattern_for(klass, 'deleter_id').should == nil
      end
    end
  end

  describe "defaults" do
    it "should define about creator_id, updater_id" do
      @config.defaults
      @config.patterns.length.should == 2
      [Foo, Bar, Baz].each do |klass|
        @config.pattern_for(klass, 'creator_id').should_not be_nil
        @config.pattern_for(klass, 'updater_id').should_not be_nil
        @config.pattern_for(klass, 'deleter_id').should     be_nil
        @config.pattern_for(klass, 'creator_by').should     be_nil
        @config.pattern_for(klass, 'updater_by').should     be_nil
        @config.pattern_for(klass, 'deleter_by').should     be_nil
      end
    end

    it "should define about creator_id, updater_id, deleter_id with_destroy" do
      @config.with_destroy = true
      @config.defaults
      @config.patterns.length.should == 3
      [Foo, Bar, Baz].each do |klass|
        @config.pattern_for(klass, 'creator_id').should_not be_nil
        @config.pattern_for(klass, 'updater_id').should_not be_nil
        @config.pattern_for(klass, 'deleter_id').should_not be_nil
        @config.pattern_for(klass, 'creator_by').should be_nil
        @config.pattern_for(klass, 'updater_by').should be_nil
        @config.pattern_for(klass, 'deleter_by').should be_nil
      end
    end
  end


  describe "compatibles" do
    it "should define about creator_by, updater_by" do
      @config.compatibles
      @config.patterns.length.should == 2
      [Foo, Bar, Baz].each do |klass|
        @config.pattern_for(klass, 'creator_id').should be_nil
        @config.pattern_for(klass, 'updater_id').should be_nil
        @config.pattern_for(klass, 'deleter_id').should be_nil
        @config.pattern_for(klass, 'created_by').should_not be_nil
        @config.pattern_for(klass, 'updated_by').should_not be_nil
        @config.pattern_for(klass, 'deleted_by').should be_nil
      end
    end

    it "should define about creator_by, updater_by, deleter_by with_destroy" do
      @config.with_destroy = true
      @config.compatibles
      @config.patterns.length.should == 3
      [Foo, Bar, Baz].each do |klass|
        @config.pattern_for(klass, 'creator_id').should be_nil
        @config.pattern_for(klass, 'updater_id').should be_nil
        @config.pattern_for(klass, 'deleter_id').should be_nil
        @config.pattern_for(klass, 'created_by').should_not be_nil
        @config.pattern_for(klass, 'updated_by').should_not be_nil
        @config.pattern_for(klass, 'deleted_by').should_not be_nil
      end
    end
  end

  describe MagicUserstamp::Config::Pattern do
    describe "args_for_stampable_on" do
      
      it "should return args to call MagicUserstamp::Stampable.stampable_on" do
        @config.defaults
        p1 = @config.pattern_for(Foo, "creator_id")
        p1.args_for_stampable_on.should == [:create, {
            :attribute => :creator_id, 
            :stamper_class_name=>"User", 
            :stamper_attr_name=>nil}]
      end
      
      it "should return args to call MagicUserstamp::Stampable.stampable_on with options" do
        @config.on(:update, :updater_id, :actual_hook => :before_update, 
          :stamper_name => 'foo_updater', :stamper_class_name => 'Foo',
          :stamper_attr_name => 'cd')
        p1 = @config.pattern_for(Foo, "updater_id")
        p1.args_for_stampable_on.should == [:update, {
            :attribute => :updater_id,
            :actual_hook => :before_update, 
            :stamper_name => 'foo_updater', :stamper_class_name => 'Foo',
            :stamper_attr_name => 'cd'}]
      end
      
    end
    
  end



end
