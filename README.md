# ServiceNow

This Gem uses [Service Now's REST Api](http://wiki.servicenow.com/index.php?title=REST_API). It has only been used with reading & creating incidents so far.

## Installation

Add this line to your application's Gemfile:

    gem 'service_now'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install service_now

## Usage

###Creating an Incident
```ruby
params = {
    netid: 'csw3',
    name: 'Casey Watts',
    location: 'Berkeley College',
    avg_bandwidth: '1mbps',
    comment: 'just seems slow'
    mac: 'AA:BB:CC:DD:EE:FF'
}

def create_incident(params)
  ServiceNow::Configuration.configure(:sn_url => 'https://yaletest.service-now.com', :sn_username => ENV['SN_USERNAME'], :sn_password => ENV['SN_PASSWORD'])
  inc = ServiceNow::Incident.new
  inc.short_description = "Problem With Wifi"
  inc.description = "netid: #{params[:netid]}\nname: #{params[:name]}\nlocation: #{params[:location]}\nbandwidth: #{params[:avg_bandwidth]}\ncomment: #{params[:comments]}\nmac: #{params[:mac]}"
  inc.caller_id = ServiceNow::User.find(params[:netid]).sys_id
  inc.save!
end
```

### Specifications
For details on the planned usage of this gem which may or may not be implemented yet, see [specs.md](specs.md).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request