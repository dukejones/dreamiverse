require 'test_helper'

class EntriesControllerTest < ActionController::TestCase

  test "create action with an invalid entry should work" do
    @controller.stubs(:parse_time).returns(Time.now)
    Entry.any_instance.stubs(:set_emotions)
    user = User.make

    create_params = { "entry"=>{ "type"=>"dream", "title"=>"", "body"=>"some text", "sharing_level"=>"500"}, "new_entry_mode"=>"1", "what_tags"=>["ALL  TIME"] }
    post :create, create_params, {:user_id => user.id}
    assert_response :redirect
    assert flash[:alert].blank?, 'No error.'
    
    create_params['entry']['body'] = ""
    post :create, create_params, {:user_id => user.id}
    assert_response :success
    assert flash[:alert] =~ /body/i, "Error for blank body"
    
  end
end
