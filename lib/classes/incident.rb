module ServiceNow
    class Incident

        def inspect
            @attributes.each do |k, v|
                puts "#{k} => #{v}"
            end
        end

        def initialize(attributes = {}, saved_on_sn = false, internal_call = false)
            Incident.check_configuration
            symbolized_attributes = Hash[attributes.map{|k, v| [k.to_sym, v]}]
            if !symbolized_attributes[:number].nil? && !internal_call # allow setting INC number if it's called internally
                raise "SN::ERROR: You are not allowed to set INC Number manually, the server will take care of that"
            end
            @attributes = symbolized_attributes
            @saved_on_sn = saved_on_sn
        end
 
        def attributes
            @attributes
        end

        def client # must be used only when displayvable is false
            return User.find_by_sys_id(self.caller_id)
        end

        def method_missing(method, args = nil)
            method_name = method.to_s
            if match = method_name.match(/(.*)=/) # writer method
                attribute = match[1]
                if attribute == "number" && @saved_on_sn
                    raise "SN::ERROR: You are not allowed to set INC Number manually, the server will take care of that"
                end
                @attributes[attribute.to_sym] = args
            else # reader method
                @attributes[method_name.to_sym]
            end
        end

        def save!
            # if this is a new incident (still in memory and not on SN), and the user set the Incident number
            # we raise an exception
            if !@attributes[:number].nil? && !@saved_on_sn
                raise "SN::ERROR: You are not allowed to set INC Number manually, the server will take care of that"
            end
            # we only create new incidents if it's not saved already
            if !@saved_on_sn
                response = Configuration.post_resource(table = "incident").post(self.attributes.to_json)
            else
                response = Configuration.update_resource(self.number, table = "incident").post(self.attributes.to_json)
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
            @saved_on_sn = true
            self
        end

        def self.find(inc_number)
            Incident.check_configuration
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
            Incident.check_configuration
            response = Configuration.get_resource(query_hash, table = "incident").get();
            hash = JSON.parse(response, { :symbolize_names => true })
            array_of_records = hash[:records]
            array_of_inc = []
            array_of_records.each do |record|
                array_of_inc << Incident.new(attributes = record, saved_on_sn = true, internal_call = true)
            end
            array_of_inc
        end

        private
            def self.check_configuration
                if $root_url.nil? || $username.nil? || $password.nil?
                    raise "SN::Error: You have not configured yet, please run ServiceNow::Configuration.configure() first"
                end
            end
    end
end