# == Schema Information
# Schema version: 47
#
# Table name: info_request_events
#
#  id               :integer         not null, primary key
#  info_request_id  :integer         not null
#  event_type       :text            not null
#  params_yaml      :text            not null
#  created_at       :datetime        not null
#  described_state  :string(255)     
#  calculated_state :string(255)     
#

# models/info_request_event.rb:
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: info_request_event.rb,v 1.28 2008-03-31 19:15:38 francis Exp $

class InfoRequestEvent < ActiveRecord::Base
    belongs_to :info_request
    validates_presence_of :info_request

    belongs_to :info_request_event_id

    validates_presence_of :event_type
    validates_inclusion_of :event_type, :in => [
        'sent', 
        'resent', 
        'followup_sent', 
        'edit', # title etc. edited in admin interface
        'edit_outgoing', # outgoing message edited in admin interface
        'manual', # you did something in the db by hand
        'response'
    ]

    # user described state (also update in info_request)
    validates_inclusion_of :described_state, :in => [ 
        nil,
        'waiting_response',
        'waiting_clarification', 
        'not_held',
        'rejected', 
        'successful', 
        'partially_successful',
        'requires_admin'
    ]

    # Full text search indexing
    acts_as_solr :fields => [ 
        { :solr_text_main => :text },
        { :title => :text },
        { :status => :string },
        { :requested_by => :string },
        { :requested_from => :string },
        { :created_at => :date },
        { :variety => :string }
    ], :if => "$do_solr_index"
    def status # for name in Solr queries
        self.calculated_state
    end
    def requested_by
        if self.event_type == 'sent' 
            self.info_request.user.url_name
        else
            nil
        end
    end
    def requested_from
        if self.event_type == 'sent' 
            self.info_request.public_body.url_name
        else
            nil
        end
    end
    def solr_text_main
        text = ''
        if self.event_type == 'sent' 
            text = text + self.outgoing_message.body_without_salutation + "\n\n"
        elsif self.event_type == 'followup_sent'
            text = text + self.outgoing_message.body_without_salutation + "\n\n"
        elsif self.event_type == 'response'
            text = text + self.incoming_message.get_text_for_indexing + "\n\n"
        else
            # nothing
        end
        return text
    end
    def title
        if self.event_type == 'sent' 
            return self.info_request.title
        end
        return ''
    end
    def indexed_by_solr
        if ['sent', 'followup_sent', 'response'].include?(self.event_type)
            return true
        else
            return false
        end
    end
    def variety
        self.event_type
    end

    # We store YAML version of parameters in the database
    def params=(params)
        self.params_yaml = params.to_yaml
    end
    def params
        YAML.load(self.params_yaml)
    end

    # Find related incoming message
    # XXX search for the find below and call this function more instead
    def incoming_message
        if not ['response'].include?(self.event_type)
            return nil
        end

        if not self.params[:incoming_message_id]
            raise "internal error, no incoming message id for response event"
        end

        return IncomingMessage.find(self.params[:incoming_message_id].to_i)
    end

    # Find related outgoing message
    # XXX search for the find below and call this function more instead
    def outgoing_message
        if not [ 'edit_outgoing', 'sent', 'resent', 'followup_sent' ].include?(self.event_type)
            return nil
        end

        if not self.params[:outgoing_message_id]
            raise "internal error, no outgoing message id for event type which expected one"
        end

        return OutgoingMessage.find(self.params[:outgoing_message_id].to_i)
    end

    # Display version of status
    def display_status
        if incoming_message.nil?
            raise "display_status only works for incoming messages right now"
        end
        status = self.calculated_state
        if status == 'waiting_response'
            "Acknowledgement"
        elsif status == 'waiting_clarification'
            "Clarification request"
        elsif status == 'not_held'
            "Information not held"
        elsif status == 'rejected'
            "Rejection"
        elsif status == 'partially_successful'
            "Partially successful response"
        elsif status == 'successful'
            "Successful response"
        elsif status == 'requires_admin'
            "Unusual response"
        else
            raise "unknown status " + status
        end
    end


end


