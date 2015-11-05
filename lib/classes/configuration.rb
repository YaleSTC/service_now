module ServiceNow
    class Configuration

        def self.configure(auth_hash = {})
            $root_url = auth_hash[:sn_url].sub(/(\/)+$/, '') #remove trailing slash if there are any
            $username = auth_hash[:sn_username]
            $password = auth_hash[:sn_password]
            "SN::Success: Configuration successful"
        end

        def self.get_resource(query_hash = {}, displayvalue = false, table)
            # to be filled in
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSONv2&sysparm_action=getRecords&sysparm_query=#{hash_to_query(query_hash)}&displayvalue=#{displayvalue}"), $username, $password)
        end

        def self.post_resource(table)
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSONv2&sysparm_action=insert"), $username, $password)
        end

        def self.update_resource(incident_number, table)
           RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSONv2&sysparm_query=number=#{incident_number}&sysparm_action=update"), $username, $password)
        end

        private
            def self.hash_to_query(query_hash = {})
                if query_hash.empty?
                    return ""
                end
                query_string = []
                query_hash.each do |k, v|
                    key_str = k.to_s
                    value_str = v.to_s
                    # if we are querying based on short_description or description
                    # we use a partial match
                    if key_str == "short_description" || key_str == "description"
                        query_string << key_str + "LIKE" + value_str
                    else
                        query_string << key_str + "=" + value_str
                    end
                end
                query_string.join('^')
            end
    end
end
