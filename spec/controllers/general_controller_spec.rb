require File.dirname(__FILE__) + '/../spec_helper'

describe GeneralController, "when searching" do
    integrate_views
    fixtures :users, :outgoing_messages, :incoming_messages, :raw_emails, :info_requests, :info_request_events, :public_bodies, :comments

    before do
        # XXX - what is proper way to do this only once?
        if not $general_controller_built_xapian_index
            rebuild_xapian_index
            $general_controller_built_xapian_index = true
        end
    end

    it "should render the front page successfully" do
        get :frontpage
        response.should be_success
    end

    it "should redirect from search query URL to pretty URL" do
        post :search_redirect, :query => "mouse" # query hidden in POST parameters
        response.should redirect_to(:action => 'search', :combined => "mouse") # URL /search/:query
    end
  
    it "should find info request when searching for '\"fancy dog\"'" do
        get :search, :combined => ['"fancy dog"']
        response.should render_template('search')

        assigns[:xapian_requests].matches_estimated.should == 1
        assigns[:xapian_requests].results.size.should == 1
        assigns[:xapian_requests].results[0][:model].should == info_request_events(:useless_outgoing_message_event)

        assigns[:xapian_requests].words_to_highlight == ["fancy", "dog"]
    end

    it "should show help when searching for nothing" do
        get :search_redirect, :query => nil
        response.should render_template('search')
        assigns[:total_hits].should be_nil
        assigns[:query].should be_nil
    end

    it "should find public body and incoming message when searching for 'geraldine quango'" do
        get :search, :combined => ['geraldine quango']
        response.should render_template('search')

        assigns[:xapian_requests].matches_estimated.should == 1
        assigns[:xapian_requests].results.size.should == 1
        assigns[:xapian_requests].results[0][:model].should == info_request_events(:useless_incoming_message_event)

        assigns[:xapian_bodies].matches_estimated.should == 1
        assigns[:xapian_bodies].results.size.should == 1
        assigns[:xapian_bodies].results[0][:model].should == public_bodies(:geraldine_public_body)
    end
end

