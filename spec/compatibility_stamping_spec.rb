require File.join(File.dirname(__FILE__), 'spec_helper')

describe MagicUserstamp do

  MagicUserstamp.compatibility_mode = true
  
  class CompatiblePerson < ActiveRecord::Base
    set_table_name('people')
    model_stamper
  end  
  
  class CompatibleComment < ActiveRecord::Base
    set_table_name('comments')
    stampable   :stamper_class_name => :compatible_person
    belongs_to  :post
   end

  MagicUserstamp.compatibility_mode = false
  
  fixtures :people, :comments 

  before(:each) do
    @delynn = CompatiblePerson.find(people(:delynn).id)
    @nicole = CompatiblePerson.find(people(:nicole).id)
    @first_comment = CompatibleComment.find(comments(:first_comment).id)
    @second_comment = CompatibleComment.find(comments(:second_comment).id)
    CompatiblePerson.stamper = @delynn
  end

  it "comment_creation_with_stamped_object" do
    CompatiblePerson.stamper.should == @delynn.id

    comment = CompatibleComment.create(:comment => "Test Comment")
    comment.created_by.should == @delynn.id
    comment.updated_by.should == @delynn.id
    comment.creator.should ==    @delynn
    comment.updater.should ==    @delynn
  end

  it "comment_creation_with_stamped_integer" do
    CompatiblePerson.stamper = 2
    CompatiblePerson.stamper.should == 2

    comment = CompatibleComment.create(:comment => "Test Comment - 2")
    comment.created_by.should == @nicole.id
    comment.updated_by.should == @nicole.id
    comment.creator.should ==    @nicole
    comment.updater.should ==    @nicole
  end
  
  it "comment_updating_with_stamped_object" do
    CompatiblePerson.stamper = @nicole
    assert_equal @nicole.id, CompatiblePerson.stamper

    @first_comment.comment << " - Updated"
    @first_comment.save
    @first_comment.reload
    @first_comment.created_by.should == @delynn.id
    @first_comment.updated_by.should == @nicole.id
    @first_comment.creator.should ==    @delynn   
    @first_comment.updater.should ==    @nicole   
  end

  it "comment_updating_with_stamped_integer" do
    CompatiblePerson.stamper = 2
    CompatiblePerson.stamper.should == 2

    @first_comment.comment << " - Updated"
    @first_comment.save
    @first_comment.reload
    @first_comment.created_by.should == @delynn.id
    @first_comment.updated_by.should == @nicole.id
    @first_comment.creator.should ==    @delynn
    @first_comment.updater.should ==    @nicole
  end
end
