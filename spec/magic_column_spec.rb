# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

describe Userstamp do
  
  Userstamp::Config.setup do |config|
    # config.verbose = true

    config.defaults(:stamper_class_name => 'MagicPerson', :stampable_class_names => %w(MagicPost))
    config.compatibles(:stamper_class_name => 'MagicPerson', :stampable_class_names => %w(MagicComment))

    config.with_options(:stamper_class_name => 'MagicPerson', :stamper_attr_name => :name, :stampable_class_names => %w(MagicPing)) do |c|
      c.on(:create , :creator_name)
      c.on(:update , :updater_name)
      # c.on(:destroy, :deleter_name)
    end

    config.defaults(:stamper_class_name => 'MagicUser')
  end

  class MagicUser < ActiveRecord::Base
    set_table_name 'users'
    model_stamper
  end

  class MagicPerson < ActiveRecord::Base
    set_table_name 'people'
    model_stamper
  end

  class MagicPost < ActiveRecord::Base
    set_table_name 'posts'
    # stampable :stamper_class_name => :person
  end

  class MagicComment < ActiveRecord::Base
    set_table_name 'comments'
    # stampable :stamper_class_name => :person
  end

  class MagicPing < ActiveRecord::Base
    set_table_name 'pings'
    # stampable :stamper_class_name => :person
  end

  after(:all) do
    Userstamp::Config.clear
  end
  
  fixtures :users, :people, :posts
  
  before(:each) do
    @zeus = MagicUser.find(users(:zeus).id)
    @hera = MagicUser.find(users(:hera).id)
    @delynn = MagicPerson.find(people(:delynn).id)
    @nicole = MagicPerson.find(people(:nicole).id)
    @first_post = MagicPost.find(posts(:first_post).id)
    @second_post = MagicPost.find(posts(:second_post).id)
    MagicUser.stamper = @zeus
    MagicPerson.stamper = @delynn
  end

  it "Userstamp.config.pattern_for" do
    Userstamp.config.patterns.length.should == 8
    p1 = Userstamp.config.pattern_for(MagicUser, "creator_id")
    p1.should_not be_nil
    p2 = Userstamp.config.pattern_for(MagicPerson, "creator_id")
    p2.should_not be_nil
    p1 = Userstamp.config.pattern_for(MagicPost, "creator_id")
    p1.should_not be_nil
  end
  

  it "person_creation_with_stamped_object" do
    MagicUser.stamper.should == @zeus.id
    
    person = MagicPerson.create(:name => "David")
    person.creator_id.should == @zeus.id
    person.updater_id.should == @zeus.id
    person.creator.should == @zeus
    person.updater.should == @zeus
  end

  it "person_creation_with_stamped_integer" do
    MagicUser.stamper = 2
    MagicUser.stamper.should == 2

    person = MagicPerson.create(:name => "Daniel")
    person.creator_id.should ==  @hera.id 
    person.updater_id.should ==  @hera.id 
    person.creator.should ==     @hera 
    person.updater.should ==     @hera 
  end

  it "post_creation_with_stamped_object" do
    MagicPerson.stamper.should == @delynn.id

    post = MagicPost.create(:title => "Test Post - 1")
    post.creator_id.should == @delynn.id
    post.updater_id.should ==  @delynn.id
    post.creator.should ==     @delynn
    post.updater.should ==     @delynn
  end

  it "post_creation_with_stamped_integer" do
    MagicPerson.stamper = 2
    MagicPerson.stamper.should == 2

    post = MagicPost.create(:title => "Test Post - 2")
    post.creator_id.should == @nicole.id
    post.updater_id.should == @nicole.id
    post.creator.should ==    @nicole
    post.updater.should ==    @nicole
  end

  it "person_updating_with_stamped_object" do
    MagicUser.stamper = @hera
    MagicUser.stamper.should == @hera.id

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    @delynn.creator.should ==    @zeus
    @delynn.updater.should ==    @hera
    @delynn.creator_id.should == @zeus.id
    @delynn.updater_id.should == @hera.id
  end

  it "person_updating_with_stamped_integer" do
    MagicUser.stamper = 2
    MagicUser.stamper.should == 2

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    @delynn.creator_id.should == @zeus.id
    @delynn.updater_id.should == @hera.id
    @delynn.creator.should ==    @zeus
    @delynn.updater.should ==    @hera
  end

  it "post_updating_with_stamped_object" do
    MagicPerson.stamper = @nicole
    MagicPerson.stamper.should == @nicole.id

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    @first_post.creator_id.should == @delynn.id
    @first_post.updater_id.should == @nicole.id
    @first_post.creator.should ==    @delynn
    @first_post.updater.should ==    @nicole
  end

  it "post_updating_with_stamped_integer" do
    MagicPerson.stamper = 2
    MagicPerson.stamper.should == 2

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    @first_post.creator_id.should == @delynn.id
    @first_post.updater_id.should == @nicole.id
    @first_post.creator.should ==    @delynn
    @first_post.updater.should ==    @nicole
  end

end

