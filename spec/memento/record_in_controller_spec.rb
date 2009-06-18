require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class FooController < ActionController::Base
  
  private
  
end

describe Memento::RecordInController do
  
  before do
    setup_db
    setup_data
    @controller = FooController.new
    @controller.stub!(:current_user).and_return(@user)
    @headers = {}
    @controller.stub!(:response).and_return(mock("response", :headers => @headers))
  end
  
  after do
    shutdown_db
  end
  
  it "should add recording-method to ActionController::Base" do
    FooController.private_instance_methods.should include("recording")
  end
  
  it "should call memento#recording with user and block" do
    project = Project.create!
    @controller.send(:recording) do
      project.update_attribute(:name, "P7")
    end
    project.reload.name.should eql("P7")
    project.memento_states.count.should eql(1)
    Memento::Session.count.should eql(1)
  end
  
  it "should set header X-MementoSessionId" do
    @controller.send(:recording) { Project.create!.update_attribute(:name, "P7") }
    @headers.should == {'X-MementoSessionId' => Memento::Session.last.id }
  end
  
  it "should return result of given block" do
    @controller.send(:recording) do
      1 + 2
    end.should eql(3)
  end
  
end