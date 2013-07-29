require "service_now/version"
require "rest_client"
require "json"
require "uri"

module ServiceNow
    $root_url = nil
    $username = nil
    $password = nil

    class Configuration

        def self.configure(auth_hash = {})
            $root_url = auth_hash[:sn_url].sub(/(\/)+$/, '') #remove trailing slash if there are any
            $username = auth_hash[:sn_username]
            $password = auth_hash[:sn_password]
            "SN::Success: Configuration successful"
        end

        def self.get_resource(query_hash = {}, displayvalue = true, table)
            # to be filled in
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_action=getRecords&sysparm_query=#{hash_to_query(query_hash)}&displayvalue=#{displayvalue}"), $username, $password)
        end

        def self.post_resource(table)
            RestClient::Resource.new($root_url + "/#{table}.do?JSON&sysparm_action=insert", $username, $password)
        end

        def self.update_resource(incident_number, table)
           RestClient::Resource.new($root_url + "/#{table}.do?JSON&sysparm_query=number=#{incident_number}&sysparm_action=update", $username, $password) 
        end

        private
            def self.hash_to_query(query_hash = {})
                query_string = []
                query_hash.each do |k, v|
                    query_string << k.to_s + "=" + v.to_s
                end
                query_string.join('^')
            end
    end

    class User

        def initialize(attributes = {})
            @attributes = attributes
        end

        def attributes
            @attributes
        end

        # buggy, could actually return incidents
        def self.find(netid)
            query_hash = {}
            query_hash[:user_name] = netid
            response = Configuration.get_resource(query_hash = query_hash, table = "sys_user").get()
            hash = JSON.parse(response, { :symbolize_names => true })
            # there should be only one
            user = User.new(hash[:records][0])
            if user.attributes.nil?
                "SN::Alert: No user with netID: #{netid} found"
            else
                user
            end
        end

        def self.find_by_sys_id(sys_id)
            query_hash = {}
            query_hash[:sys_id] = sys_id
            response = Configuration.get_resource(query_hash = query_hash, table = "sys_user").get()
            hash = JSON.parse(response, { :symbolize_names => true })
            user = User.new(hash[:records][0])
            if user.attributes.nil?
                "SN::Alert: No user with sys_id: #{sys_id} found"
            else
                user
            end
        end

        # buggy, could actually return incidents
        def self.find_by_name(name)
            query_hash = {}
            query_hash[:name] = name
            response = Configuration.get_resource(query_hash = query_hash, table = "sys_user").get()
            hash = JSON.parse(response, { :symbolize_names => true })
            user = User.new(hash[:records][0])
            if user.attributes.nil?
                "SN::Alert: No user with user_name: #{name} found"
            else
                user
            end
        end

        def method_missing(method, args = nil)
            method_name = method.to_s
            @attributes[method_name.to_sym]
        end
    end

    class Incident

        def initialize(attributes = {}, saved_on_sn = false, internal_call = false)
            if $root_url.nil? || $username.nil? || $password.nil?
                raise "SN::Error: You have not configured yet, please run ServiceNow::Configuration.configure() first"
            end
            symbolized_attributes = Hash[attributes.map{|k, v| [k.to_sym, v]}]
            if !symbolized_attributes[:number].nil? && !internal_call
                raise "SN::ERROR: You are not allowed to set INC Number manually, the server will take care of that"
            end
            @attributes = symbolized_attributes
            @saved_on_sn = saved_on_sn
        end
 
        def attributes
            @attributes
        end

        def client # must be used only when displayvable is true
            return User.find_by_name(self.caller_id)
        end

        def method_missing(method, args = nil)
            method_name = method.to_s
            if match = method_name.match(/(.*)=/) # writer method
                attribute = match[1]
                if attribute.eql? "number"
                    raise "SN::ERROR: You are not allowed to set INC Number manually, the server will take care of that"
                end
                @attributes[attribute.to_sym] = args
            else # reader method
                @attributes[method_name.to_sym]
            end
        end

        def save!
            # we only create new incidents if it's not saved already
            if !@saved_on_sn
                response = Configuration.post_resource.post(self.attributes.to_json)
                @saved_on_sn = true
            else
                response = Configuration.update_resource(self.number).post(self.attributes.to_json)
                # debug
                puts response
                # even though we know it's saved already, just set it again to be sure
                @saved_on_sn = true
            end
            hash = JSON.parse(response, { :symbolize_names => true })
            # this is the object
            # and there is always only one
            # since we're creating or updating
            inc_object = hash[:records][0]
            inc_object.each do |key, value|
                key_name = key.to_s
                eval("self.#{key_name} = value")
            end
            self
        end

        def self.find(inc_number)
            inc_string = inc_number.to_s.match(/[123456789]+\d*$/).to_s
            if inc_string.length > 7
                raise "SN::Error: invalid Incident number"
            end
            query_hash = {}
            query_hash[:number] = "INC" + "0"*(7-inc_string.length) + inc_string
            response = Configuration.get_resource(query_hash, table = "incident").get();
            # returned hash
            hash = JSON.parse(response, { :symbolize_names => true })
            # return the Incident object
            inc_obj = Incident.new(attributes = hash[:records][0], saved_on_sn = true, internal_call = true)
            if inc_obj.attributes.nil?
                "SN::Alert: No incident with incident number #{query_hash[:number]} found"
            else
                inc_obj
            end
        end

        def self.where(query_hash = {})
            response = Configuration.get_resource(query_hash, table = "incident").get();
            hash = JSON.parse(response, { :symbolize_names => true })
            array_of_records = hash[:records]
            array_of_inc = []
            array_of_records.each do |record|
                array_of_inc << Incident.new(attributes = record, saved_on_sn = true, internal_call = true)
            end
            array_of_inc
        end
    end
end
