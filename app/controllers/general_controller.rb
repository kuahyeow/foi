# app/controllers/general_controller.rb:
# For pages like front page, general search, that aren't specific to a
# particular model.
#
# Copyright (c) 2008 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: general_controller.rb,v 1.37 2008-09-05 09:05:05 francis Exp $

class GeneralController < ApplicationController

    # Fancy javascript smancy for auto complete search on front page
    def auto_complete_for_public_body_query
        @public_bodies = public_body_query(params[:public_body][:query])

        render :partial => "public_body_query"
    end

    # Actual front page
    def frontpage
        # Public body search on the left
        @public_bodies = []
        @query_made = false
        if params[:public_body] and params[:public_body][:query]
            # Try and do exact match - redirect if it is made
            @public_body = PublicBody.find_by_name(params[:public_body][:query])
            if not @public_body.nil?
                redirect_to public_body_url(@public_body)
            end
            # Otherwise use search engine to find public body
            @public_bodies = public_body_query(params[:public_body][:query])
            @query_made = true
        end

        # Get all successful requests for display on the right  
        query = 'variety:response (status:successful OR status:partially_successful)'
        sortby = "described"
        @xapian_object = perform_search([InfoRequestEvent], query, sortby, 'request_collapse', 3)
    end

    # New, improved front page!
    def new_frontpage
        @popular_bodies = PublicBody.find(:all, :select => "*, (select count(*) from info_requests where info_requests.public_body_id = public_bodies.id) as c", :order => "c desc", :limit => 8)
        @random_requests = InfoRequest.find(:all, :order => "random()", :limit => 8, :conditions => ["described_state = ? and prominence = ?", 'successful', 'normal'] )
    end

    # Just does a redirect from ?query= search to /query
    def search_redirect
        @query = params[:query]
        @sortby = params[:sortby]
        @bodies = params[:bodies]
        if @query.nil? || @query.empty?
            @query = nil
            render :action => "search"
        else
            if (@bodies == '1') && (@sortby.nil? || @sortby.empty?)
                @postfix = 'bodies'
            else
                @postfix = @sortby
            end
            redirect_to search_url(@query, @postfix)
        end
    end

    # Actual search
    def search
        # XXX Why is this so complicated with arrays and stuff? Look at the route
        # in config/routes.rb for comments.
        combined = params[:combined]
        @sortby = nil
        @bodies = false # searching from front page, largely for a public authority
        # XXX currently /described isn't linked to anywhere, just used in RSS and for /list/successful
        # This is because it's confusingly different from /newest - but still useful for power users.
        if combined.size > 1 && (['newest', 'described', 'bodies'].include?(combined[-1]))
            @postfix = combined[-1]
            combined = combined[0..-2]
            if @postfix == 'bodies'
                @bodies = true
            else
                @sortby = @postfix
            end
        end
        @query = combined.join("/")

        # Query each type separately for separate display (XXX we are calling
        # perform_search multiple times and it clobbers per_page for each one,
        # so set as separate var)
        @xapian_requests = perform_search([InfoRequestEvent], @query, @sortby, 'request_collapse', 25)
        @requests_per_page = @per_page
        @xapian_bodies = perform_search([PublicBody], @query, @sortby, nil, 5)
        @bodies_per_page = @per_page
        @xapian_users = perform_search([User], @query, @sortby, nil, 5)
        @users_per_page = @per_page

        @this_page_hits = @xapian_requests.results.size + @xapian_bodies.results.size + @xapian_users.results.size
        @total_hits = @xapian_requests.matches_estimated + @xapian_bodies.matches_estimated + @xapian_users.matches_estimated

        # Spelling and highight words are same for all three queries
        @spelling_correction = @xapian_requests.spelling_correction
        @highlight_words = @xapian_requests.words_to_highlight

        @track_thing = TrackThing.create_track_for_search_query(@query)
        @feed_autodetect = [ { :url => do_track_url(@track_thing, 'feed'), :title => @track_thing.params[:title_in_rss] } ]

        # No point bots crawling all the pages of search results.
        @no_crawl = true

        # If we came from the front page (@bodies is true) and found no bodies
        #if @bodies && @xapian_bodies.results.size == 0
        #    flash[:notice] = 'No authorities found with that name. <a href="/body/list/other">Browse all</a> or <a href="/help/about#missing_body">ask us to add one</a>.'
        #end
    end

    # For debugging
    def fai_test
        sleep 10
        render :text => "awake\n"
    end

    private

    # Used in front page search for public body
    def public_body_query(query)
        # XXX try using search now we have spell correction?

        criteria = '%' + query + '%'
        @public_bodies = PublicBody.find(:all, 
                    :conditions => ["lower(name) like lower(?) or lower(short_name) like lower(?)", criteria, criteria],
                    :order => 'name', :limit=>10)  
        return @public_bodies
    end

end
 
