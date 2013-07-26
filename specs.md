
The main open question in the specs below (at least right now) is how to handle associating users with incidents. That is, what are the properties used by SN to reliably identify clients for incidents, requests, etc. Do we create a class such as SN::Client that wraps the properties of an incident's client?

## Configuration

Ideally, users of this gem would be able to do something like:

    SN::Configuration.configure auth_user: "my_user", auth_pass: "my_pass", sn_url: "http://yaletest.service-now.com"

## Incidents

### Creating
    
    incident = SN::Incident.new(client: "Adam Bray", short_description: "Computer has a virus")
    incident.save! # submits request to SN; returns SN::Incident which wraps the newly created incident

### Searching
    
    incidents = SN::Incident.where(description: "virus", client: "Adam Bray")
    # returns an array of objects of class 'SN::Incident'
    # note we need to discuss the exact names for things like 'client', 'client netid', etc
    
    incident = SN::Incident.find("INC0003123")
    # same as:
    incident = SN::Incident.find(3123)
    # returns on SN::Incident
    
### Reading

    incident = SN::Incident.find(3123)
    incident.short_description
    # "Client has a computer virus after watching lolcats"
    incident.description
    # Returns the full description
    client = incident.client
    # This should ideally return something that behaves like a user object, maybe a class SN::Client
    client.name
    # "Adam Bray"
    client.email
    # "adam.bray@example.com"

### Updating

    incident = SN::Incident.find(3123)
    incident.short_description = "Client has a computer virus after watching loldogs"
    incident.save!
    
### Destroying

For now, I don't think we should implement destroying incidents.
    
