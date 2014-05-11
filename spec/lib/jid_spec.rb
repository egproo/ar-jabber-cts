require 'spec_helper'

describe JID do
  describe 'name' do
    it 'is parsed' do
      JID.new('test').name.should == 'test'
    end

    it 'can be empty' do
      JID.new('test1@/test3').name.should == ''
    end
  end

  describe 'node' do
    it 'is parsed' do
      JID.new('test1@test2').node.should == 'test1'
    end

    it 'can be empty' do
      JID.new('@test2').node.should == ''
    end

    it 'is nil when not present' do
      JID.new('test2').node.should == nil
    end
  end

  describe 'resource' do
    it 'is parsed' do
      JID.new('test1@test2/Test3').resource.should == 'Test3'
    end

    it 'can be empty' do
      JID.new('test@test2/').resource.should == ''
    end

    it 'is not parsed when node is not given' do
      JID.new('test2/test3').resource.should == nil
    end

    it 'is nil when not present' do
      JID.new('test2').resource.should == nil
    end
  end

  describe 'to_s' do
    it 'prints name only' do
      JID.new('test').to_s.should == 'test'
    end

    it 'prints name with node' do
      JID.new('test1@test2').to_s.should == 'test1@test2'
    end

    it 'allows empty node' do
      JID.new('@test2').to_s.should == '@test2'
    end

    it 'allows empty resource' do
      JID.new('test1@test2/').to_s.should == 'test1@test2/'
    end

    it 'prints all components correctly' do
      JID.new('test1@test2/test3').to_s.should == 'test1@test2/test3'
    end
  end
end
