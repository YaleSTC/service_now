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
            "SN::Configuration successful"
        end

        def self.get_resource(query_hash = {})
            # to be filled in
            RestClient::Resource.new(URI.escape($root_url + "/incident.do?JSON&sysparm_action=getRecords&sysparm_query=#{hash_to_query(query_hash)}"), $username, $password)
        end

        def self.post_resource
            RestClient::Resource.new($root_url + "/incident.do?JSON&sysparm_action=insert", $username, $password)
        end

        def self.update_resource(incident_number)
           RestClient::Resource.new($root_url + "/incident.do?JSON&sysparm_query=number=#{incident_number}&sysparm_action=update", $username, $password) 
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

    class Incident

        def initialize(attributes = {}, saved_on_sn = false)
            @attributes = attributes
            @saved_on_sn = saved_on_sn
        end
 
        def attributes
            @attributes
        end

        def method_missing(method, args = nil)
            method_name = method.to_s
            if match = method_name.match(/(.*)=/) # writer method
                attribute = match[1]
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
            return self
        end

        def self.find(inc_number)
            inc_string = inc_number.to_s.match(/[123456789]+\d*$/).to_s
            if inc_string.length > 7
                return "SN::invalid Incident number"
            end
            query_hash = {}
            query_hash[:number] = "INC" + "0"*(7-inc_string.length) + inc_string
            response = Configuration.get_resource(query_hash).get();
            # returned hash
            hash = JSON.parse(response, { :symbolize_names => true })
            inc_obj = hash[:records][0]
            # return the Incident object
            inc_obj = Incident.new(attributes = inc_obj, saved_on_sn = true)
            if inc_obj.attributes.nil?
                "SN::No incident with incident number #{query_hash[:number]} found"
            else
                inc_obj
            end
        end

        def self.where(query_hash = {})
            response = Configuration.get_resource(query_hash).get();
            hash = JSON.parse(response, { :symbolize_names => true })
            array_of_records = hash[:records]
            array_of_inc = []
            array_of_records.each do |record|
                array_of_inc << Incident.new(attributes = record, saved_on_sn = true)
            end
            array_of_inc
        end
    end
end
