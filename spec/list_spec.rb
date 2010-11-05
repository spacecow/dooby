require 'spec_helper'

module Dooby
  describe List do
        
    before(:all) do
      @location = 'location'
    end
    
    describe '#new' do
      
      it "should load the list of items if list.yml exists" do
        File.stub(:exist?).and_return true
        YAML.stub(:load_file).and_return fake_tasks
        
        File.should_receive(:exist?).with(CURRENT_TODO_LIST_FILE).and_return true
        YAML.should_receive(:load_file).with(@location).and_return fake_tasks
        
        List.new @location
      end
    end
    
    describe '#flush' do
      it 'should empty the list of items and clear the list.yml file' do
        File.stub(:exist?).and_return true
        YAML.stub(:load_file).and_return fake_tasks
        File.stub(:open).and_return true
        
        File.should_receive(:open).with(@location, 'w').and_return true
        
        list = List.new @location
        list.flush!
        list.tasks.should be_empty
      end
    end
    
    describe 'CRUD' do
      before(:all) do
        File.stub(:exist?).and_return true
      end
      
      describe '#add' do
        it "should create an item" do
          YAML.stub(:load_file).and_return {}
        
          list = List.new @location
          @list.stub(:save!).and_return true
          task = Task.new fake_todo_text
        
          list.add task
        
          list.tasks.should_not be_empty
          list.tasks[task.id].todo.should == fake_todo_text
        end
      end
    
      describe '#delete!' do
        it "should delete an item" do
          YAML.stub(:load_file).and_return fake_tasks
                    
          list = List.new @location
          list.should_receive(:save!).and_return true
          
          task_to_delete = list.tasks.first
          
          list.delete! task_to_delete.first
          
          list.tasks.should_not include(task_to_delete.first)
        end
      end
      
      describe '#bulk_delete!' do
        before(:each) do
          YAML.stub(:load_file).and_return fake_tasks
          @list = List.new @location
          @list.stub(:save!).and_return true
          
          @list.should_receive(:save!).and_return true
        end
        
        it "should delete all the items containing a keyword" do
          @list.bulk_delete! ['#context']
          @list.tasks.should be_empty
        end
        
        it "should delete all the items containing a set of keywords" do          
          @list.bulk_delete! %w[#context @person %project]
          @list.tasks.should be_empty
        end
      end
      
      describe '#edit!' do
        it 'should delete the edited task and add a new one' do
          YAML.stub(:load_file).and_return fake_tasks
          list = List.new @location
          list.stub(:save!).and_return true
          
          list.should_receive(:save!).twice
          
          task_to_edit = list.tasks.first
          task_id = task_to_edit.first

          new_todo = 'this is the new text'
          
          new_task = list.edit! task_id do |task|
            task.todo = new_todo
          end
          
          list.tasks.should_not include task_id
          list.tasks.should include new_task.id
        end
      end
      
      describe '#tasks?' do
        it 'should return true if there are tasks' do
          YAML.stub(:load_file).and_return fake_tasks
          list = List.new @location
          
          list.tasks?.should be_true
        end
        
        it "should return false if there aren't tasks" do
          YAML.stub(:load_file).and_return {}
          list = List.new @location
          
          list.tasks?.should be_false
        end
      end
      
      describe '#find' do
        describe 'with empty array as argument' do
          it 'should return a list of all the items'
        end
        
        describe 'with special tags as argument' do
          it 'should return only the specified tags'
        end
        
        describe 'with an array of terms as argument' do
          it 'should return only the items containing all the specified tags'
        end
      end
      
      describe '#all_tags' do
        it 'should return only the tags of all the items'
      end
      
      describe '#current_item' do
        it 'should return the item tagged with :doing'
      end
    end
  end
end