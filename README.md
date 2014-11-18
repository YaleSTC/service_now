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

###Finding an Incident
```ruby
  ServiceNow::Configuration.configure(:sn_url => ENV['SN_INSTANCE'], :sn_username => ENV['SN_USERNAME'], :sn_password => ENV['SN_PASSWORD'])
  inc_number = "INC0326578"
  inc = ServiceNow::Incident.find(inc_number)
```

`inc` will contain a hash of attributes retrieved from Service Now for that incident.

```
{:caller_id=>"3f6894b60194ac0094adf4b82250a68a", :u_contact=>"3f6894b60194ac0094adf4b82250a68a", :u_kb_article=>"fbebf3339004fc40fde6c4b91cbd300a", :contact_type=>"In Person", :short_description=>"Report From STCEmailApp", :description=>"Name: Casey Watts\nNon-Yale Email: first.last@gmail.com\nCell: 4433863616\nProgram Name: \nRoom Number: BK A11\n\nModel: Mac\nOS: OSX 10.9\nSerial Number: abc123abc123\n\nDescription of Issue: My microphone isn't working. It seems to be able to hear me typing but voice won't work, even screaming isn't picked up.", :active=>"true", :activity_due=>"", :approval=>"not requested", :approval_history=>"", :approval_set=>"", :assigned_to=>"", :assignment_group=>"", :business_duration=>"", :business_stc=>"000000", :calendar_duration=>"", :calendar_stc=>"000000", :category=>"", :caused_by=>"", :child_incidents=>"0", :close_code=>"", :close_notes=>"", :closed_at=>"", :closed_by=>"", :cmdb_ci=>"", :comments=>"", :comments_and_work_notes=>"", :company=>"f66b14e1c611227b0166c3a0df4046ff", :contract=>"", :correlation_display=>"", :correlation_id=>"", :credit_cards=>"", :delivery_plan=>"", :delivery_task=>"", :due_date=>"", :encrypted_by=>"", :encryption_context=>"", :escalation=>"0", :expected_start=>"", :follow_up=>"", :group_list=>"", :impact=>"3", :incident_state=>"2", :knowledge=>"false", :location=>"", :made_sla=>"true", :notify=>"2", :number=>"INC0326578", :opened_at=>"2014-07-18 07:16:10", :opened_by=>"85da3a532b577c00fcb01abf59da1569", :order=>"0", :parent=>"", :parent_incident=>"", :priority=>"5", :problem_id=>"", :reassignment_count=>"0", :reopen_count=>"0", :rfc=>"", :severity=>"3", :skills=>"", :sla_due=>"", :ssns=>"", :state=>"1", :subcategory=>"", :sys_class_name=>"incident", :sys_created_by=>"s_stc", :sys_created_on=>"2014-07-18 07:16:10", :sys_domain=>"global", :sys_id=>"2d1d11ec240e2d00fde65a2c57b6f463", :sys_mod_count=>"0", :sys_updated_by=>"s_stc", :sys_updated_on=>"2014-07-18 07:16:10", :time_worked=>"", :u_asset_device=>"", :u_assigned=>"2014-07-18 07:16:10", :u_client=>"3f6894b60194ac0094adf4b82250a68a", :u_component=>"", :u_created_by_tier_1=>"false", :u_fpoc=>"false", :u_in_progress=>"", :u_incident_state_count=>"0", :u_incident_type=>"", :u_is_ess=>"false", :u_it_business_service=>"", :u_it_provider_service=>"", :u_lateral_assignment=>"false", :u_level_1=>"", :u_level_2=>"", :u_level_3=>"", :u_major_incident=>"false", :u_major_outage=>"false", :u_one_touch=>"false", :u_original_assignment_group=>"", :u_priority_count=>"0", :u_protocol_followed=>"false", :u_referral_count=>"0", :u_reopened=>"false", :u_resolved=>"", :u_resolved_by=>"", :u_secure_text=>"", :u_set_to_p1=>"", :upon_approval=>"proceed", :upon_reject=>"cancel", :urgency=>"3", :user_input=>"", :watch_list=>"", :work_end=>"", :work_notes=>"", :work_notes_list=>"", :work_start=>""}
```

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
  ServiceNow::Configuration.configure(:sn_url => ENV['SN_INSTANCE'], :sn_username => ENV['SN_USERNAME'], :sn_password => ENV['SN_PASSWORD'])
  inc = ServiceNow::Incident.new
  inc.short_description = "Problem With Wifi"
  inc.description = "netid: #{params[:netid]}\nname: #{params[:name]}\nlocation: #{params[:location]}\nbandwidth: #{params[:avg_bandwidth]}\ncomment: #{params[:comments]}\nmac: #{params[:mac]}"
  inc.caller_id = ServiceNow::User.find(params[:netid]).sys_id
  inc.save!
end
```

`inc.save!` will return an object with information about the incident in a hash, such as:

```
{:caller_id=>"3f6894b60194ac0094adf4b82250a68a", :u_contact=>"3f6894b60194ac0094adf4b82250a68a", :u_kb_article=>"fbebf3339004fc40fde6c4b91cbd300a", :contact_type=>"In Person", :short_description=>"Report From STCEmailApp", :description=>"Name: Casey Watts\nNon-Yale Email: first.last@gmail.com\nCell: 4433863616\nProgram Name: \nRoom Number: BK A11\n\nModel: Mac\nOS: OSX 10.9\nSerial Number: abc123abc123\n\nDescription of Issue: My microphone isn't working. It seems to be able to hear me typing but voice won't work, even screaming isn't picked up.", :active=>"true", :activity_due=>"", :approval=>"not requested", :approval_history=>"", :approval_set=>"", :assigned_to=>"", :assignment_group=>"", :business_duration=>"", :business_stc=>"000000", :calendar_duration=>"", :calendar_stc=>"000000", :category=>"", :caused_by=>"", :child_incidents=>"0", :close_code=>"", :close_notes=>"", :closed_at=>"", :closed_by=>"", :cmdb_ci=>"", :comments=>"", :comments_and_work_notes=>"", :company=>"f66b14e1c611227b0166c3a0df4046ff", :contract=>"", :correlation_display=>"", :correlation_id=>"", :credit_cards=>"", :delivery_plan=>"", :delivery_task=>"", :due_date=>"", :encrypted_by=>"", :encryption_context=>"", :escalation=>"0", :expected_start=>"", :follow_up=>"", :group_list=>"", :impact=>"3", :incident_state=>"2", :knowledge=>"false", :location=>"", :made_sla=>"true", :notify=>"2", :number=>"INC0326578", :opened_at=>"2014-07-18 07:16:10", :opened_by=>"85da3a532b577c00fcb01abf59da1569", :order=>"0", :parent=>"", :parent_incident=>"", :priority=>"5", :problem_id=>"", :reassignment_count=>"0", :reopen_count=>"0", :rfc=>"", :severity=>"3", :skills=>"", :sla_due=>"", :ssns=>"", :state=>"1", :subcategory=>"", :sys_class_name=>"incident", :sys_created_by=>"s_stc", :sys_created_on=>"2014-07-18 07:16:10", :sys_domain=>"global", :sys_id=>"2d1d11ec240e2d00fde65a2c57b6f463", :sys_mod_count=>"0", :sys_updated_by=>"s_stc", :sys_updated_on=>"2014-07-18 07:16:10", :time_worked=>"", :u_asset_device=>"", :u_assigned=>"2014-07-18 07:16:10", :u_client=>"3f6894b60194ac0094adf4b82250a68a", :u_component=>"", :u_created_by_tier_1=>"false", :u_fpoc=>"false", :u_in_progress=>"", :u_incident_state_count=>"0", :u_incident_type=>"", :u_is_ess=>"false", :u_it_business_service=>"", :u_it_provider_service=>"", :u_lateral_assignment=>"false", :u_level_1=>"", :u_level_2=>"", :u_level_3=>"", :u_major_incident=>"false", :u_major_outage=>"false", :u_one_touch=>"false", :u_original_assignment_group=>"", :u_priority_count=>"0", :u_protocol_followed=>"false", :u_referral_count=>"0", :u_reopened=>"false", :u_resolved=>"", :u_resolved_by=>"", :u_secure_text=>"", :u_set_to_p1=>"", :upon_approval=>"proceed", :upon_reject=>"cancel", :urgency=>"3", :user_input=>"", :watch_list=>"", :work_end=>"", :work_notes=>"", :work_notes_list=>"", :work_start=>""}
```

Setting `inc.u_kb_article` will set the KB Article field, but it will not apply the associated template.

### More Features

More features of this gem are documented in the specifications file. These may or may not be implemented yet, see [specs.md](specs.md).
You can also check the source files in `/lib`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
