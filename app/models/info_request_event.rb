# == Schema Information
# Schema version: 25
#
# Table name: info_request_events
#
#  id              :integer         not null, primary key
#  info_request_id :integer         
#  event_type      :text            
#  params_yaml     :text            
#  created_at      :datetime        
#

# models/info_request_event.rb:
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: info_request_event.rb,v 1.5 2008-01-10 01:13:28 francis Exp $

class InfoRequestEvent < ActiveRecord::Base
    belongs_to :info_request
    validates_presence_of :info_request

    validates_presence_of :event_type
    validates_inclusion_of :event_type, :in => ['sent', 'resent', 'followup_sent', 'followup_resent', 'edit_outgoing']

    # We store YAML version of parameters in the database
    def params=(params)
        self.params_yaml = params.to_yaml
    end
    def params
        YAML.load(self.params_yaml)
    end

    # Used for sorting with the incoming/outgoing messages
    def sent_at
        created_at
    end

end

