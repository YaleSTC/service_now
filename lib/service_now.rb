require "service_now/version"
require "rest_client"
require "json"

module ServiceNow
    $post_resource = nil
    $get_resource = nil
    $root_url = nil
    $username = nil
    $password = nil
    class Configuration
        def self.configure(auth_hash = {})
            $root_url = auth_hash[:sn_url].sub(/(\/)+$/, '') #remove trailing slash if there are any
            $username = auth_hash[:sn_username]
            $password = auth_hash[:sn_password]
            $post_resource = RestClient::Resource.new($root_url + "/incident.do?JSON&sysparm_action=insert", $username, $password)
        end
    end

    class Incident

        def initialize(attributes = {})
            @attributes = attributes
        end
 
        def attributes
            @attributes
        end

        def method_missing(method, args = nil)
            method_name = method.to_s
            if match = method_name.match(/(.*)=/) # writer method
                attribute = match[1]
                @attributes[attribute] = args
            else # reader method
                @attributes[method_name]
            end
        end

        def save!
            response = $post_resource.post(self.attributes.to_json)
            hash = JSON.parse(response, { :symbolize_names => true })
            #this is the object, and there is always only one since we're creating
            inc_object = hash[:records][0]
            inc_object.each do |key, value|
                key_name = key.to_s
                eval("self.#{key_name} = value")
            end
            return self
        end
    end
end
