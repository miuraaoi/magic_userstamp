# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

describe User do

  puts self.fixture_path

    def setup_fixtures
      # ここでなぜか fixture_path の値が変わってしまっています。。。
      self.class.fixture_path = "./spec/fixtures"
      
      return unless defined?(ActiveRecord) && !ActiveRecord::Base.configurations.blank?

      if pre_loaded_fixtures && !use_transactional_fixtures
        raise RuntimeError, 'pre_loaded_fixtures requires use_transactional_fixtures'
      end

      @fixture_cache = {}
      @@already_loaded_fixtures ||= {}

      # Load fixtures once and begin transaction.
      if run_in_transaction?
        puts "run_in_transaction? => true"
        puts "@@already_loaded_fixtures => #{@@already_loaded_fixtures.inspect}"


        if @@already_loaded_fixtures[self.class]
          @loaded_fixtures = @@already_loaded_fixtures[self.class]
        else
          load_fixtures
          @@already_loaded_fixtures[self.class] = @loaded_fixtures
        end
        ActiveRecord::Base.connection.increment_open_transactions
        ActiveRecord::Base.connection.transaction_joinable = false
        ActiveRecord::Base.connection.begin_db_transaction
      # Load fixtures for every test.
      else
        Fixtures.reset_cache
        @@already_loaded_fixtures[self.class] = nil
        load_fixtures
      end

      # Instantiate fixtures for every test if requested.
      instantiate_fixtures if use_instantiated_fixtures
    end

  fixtures :users, :people, :posts, :comments
  
  before(:each) do
    @zeus = users(:zeus)
    @hera = users(:hera)
    @delynn = people(:delynn)
    @nicole = people(:nicole)
    @first_post = posts(:first_post)
    @second_post = posts(:second_post)
    # @zeus = User.create(:name => 'zeus')
    # @hera = User.create(:name => 'hera')
    # @delynn = Person.create(:name => 'delynn', :creator_id => 1, :updater_id => 1)
    # @nicole = Person.create(:name => 'nicole', :creator_id => 2, :updater_id => 2)
    # @first_post = Post.create(:title => 'First Post', :creator_id => 1)
    # @second_post = Post.create(:title => 'Second Post', :creator_id => 1)
    User.stamper = @zeus
    Person.stamper = @delynn
  end

  it "person_creation_with_stamped_object" do
    assert_equal @zeus.id, User.stamper
    
    person = Person.create(:name => "David")
    assert_equal @zeus.id, person.creator_id
    assert_equal @zeus.id, person.updater_id
    assert_equal @zeus, person.creator
    assert_equal @zeus, person.updater
  end

  it "person_creation_with_stamped_integer" do
    User.stamper = 2
    assert_equal 2, User.stamper

    person = Person.create(:name => "Daniel")
    assert_equal @hera.id, person.creator_id
    assert_equal @hera.id,  person.updater_id
    assert_equal @hera, person.creator
    assert_equal @hera, person.updater
  end

  it "post_creation_with_stamped_object" do
    assert_equal @delynn.id, Person.stamper

    post = Post.create(:title => "Test Post - 1")
    assert_equal @delynn.id, post.creator_id
    assert_equal @delynn.id, post.updater_id
    assert_equal @delynn, post.creator
    assert_equal @delynn, post.updater
  end

  it "post_creation_with_stamped_integer" do
    Person.stamper = 2
    assert_equal 2, Person.stamper

    post = Post.create(:title => "Test Post - 2")
    assert_equal @nicole.id, post.creator_id
    assert_equal @nicole.id, post.updater_id
    assert_equal @nicole, post.creator
    assert_equal @nicole, post.updater
  end

  it "person_updating_with_stamped_object" do
    User.stamper = @hera
    assert_equal @hera.id, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus, @delynn.creator
    assert_equal @hera, @delynn.updater
    assert_equal @zeus.id, @delynn.creator_id
    assert_equal @hera.id, @delynn.updater_id
  end

  it "person_updating_with_stamped_integer" do
    User.stamper = 2
    assert_equal 2, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus.id, @delynn.creator_id
    assert_equal @hera.id, @delynn.updater_id
    assert_equal @zeus, @delynn.creator
    assert_equal @hera, @delynn.updater
  end

  it "post_updating_with_stamped_object" do
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.creator_id
    assert_equal @nicole.id, @first_post.updater_id
    assert_equal @delynn, @first_post.creator
    assert_equal @nicole, @first_post.updater
  end

  it "post_updating_with_stamped_integer" do
    Person.stamper = 2
    assert_equal 2, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.creator_id
    assert_equal @nicole.id, @first_post.updater_id
    assert_equal @delynn, @first_post.creator
    assert_equal @nicole, @first_post.updater
  end
  

end

