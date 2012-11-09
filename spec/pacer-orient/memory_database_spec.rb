require 'spec_helper'

describe "InMemory Database" do

  before do
    #by default it will use an in-memory database
    @database = Pacer.orient
    @topper = @database.create_vertex :name => 'Topper', :type => 'person'
    @ben = @database.create_vertex :name => 'Ben', :type => 'person'
    @topper_knows_ben = @database.create_edge(nil, @topper, @ben, :knows)
  end

  it "should create a node" do
    @database.v.count.should == 2
  end

  it "should create edges" do
    @database.e.count.should == 1
  end

  it "should traverse" do
    friends = @topper.out_e(:knows).in_v(:type => 'person')
    friends.first.should == @ben
  end






end
