require File.join(File.dirname(__FILE__), 'spec_helper')

describe Ddb::Userstamp do

  Ddb::Userstamp.compatibility_mode = true
  
  class Person < ActiveRecord::Base
    model_stamper
  end  
  
  class Comment < ActiveRecord::Base
    stampable   :stamper_class_name => :person
    belongs_to  :post
  end

  Ddb::Userstamp.compatibility_mode = false

  
  fixtures :people, :comments 

  before(:each) do
    @delynn = people(:delynn)
    @nicole = people(:nicole)
    @first_comment = comments(:first_comment)
    @second_comment = comments(:second_comment)
    Person.stamper = @delynn
  end

  it "comment_creation_with_stamped_object" do
    Person.stamper.should == @delynn.id

    comment = Comment.create(:comment => "Test Comment")
    comment.created_by.should == @delynn.id
    comment.updated_by.should == @delynn.id
    comment.creator.should ==    @delynn
    comment.updater.should ==    @delynn
  end

  it "comment_creation_with_stamped_integer" do
    Person.stamper = 2
    Person.stamper.should == 2

    comment = Comment.create(:comment => "Test Comment - 2")
    comment.created_by.should == @nicole.id
    comment.updated_by.should == @nicole.id
    comment.creator.should ==    @nicole
    comment.updater.should ==    @nicole
  end
  
  it "comment_updating_with_stamped_object" do
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_comment.comment << " - Updated"
    @first_comment.save
    @first_comment.reload
    @first_comment.created_by.should == @delynn.id
    @first_comment.updated_by.should == @nicole.id
    @first_comment.creator.should ==    @delynn   
    @first_comment.updater.should ==    @nicole   
  end

  it "comment_updating_with_stamped_integer" do
    Person.stamper = 2
    Person.stamper.should == 2

    @first_comment.comment << " - Updated"
    @first_comment.save
    @first_comment.reload
    @first_comment.created_by.should == @delynn.id
    @first_comment.updated_by.should == @nicole.id
    @first_comment.creator.should ==    @delynn
    @first_comment.updater.should ==    @nicole
  end
end
