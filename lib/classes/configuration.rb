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
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_action=getRecords&sysparm_query=#{hash_to_query(query_hash)}&displayvalue=#{displayvalue}"), $username, $password)
        end

        def self.post_resource(table)
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_action=insert"), $username, $password)
        end

        def self.update_resource(incident_number, table)
           RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_query=number=#{incident_number}&sysparm_action=update"), $username, $password) 
        end

        private
            def self.hash_to_query(query_hash = {})
                if query_hash.empty?
                    return ""
                end
                query_string = []
                query_hash.each do |k, v|
                    query_string << k.to_s + "=" + v.to_s
                end
                query_string.join('^')
            end
    end
end