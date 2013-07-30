module ServiceNow
    class User

        def initialize(attributes = {})
            @attributes = attributes
        end

        def attributes
            @attributes
        end

        def self.find(netid)
            User.check_configuration
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
            User.check_configuration
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

        def self.find_by_name(name)
            User.check_configuration
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

        private
            def self.check_configuration
                if $root_url.nil? || $username.nil? || $password.nil?
                    raise "SN::Error: You have not configured yet, please run ServiceNow::Configuration.configure() first"
                end
            end
    end
end