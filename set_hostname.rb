#!/usr/bin/env ruby

require 'aws-sdk'
require 'net/https'
require 'rubygems'

# Static local FQDN
fqdn = 'local.domain.com'

# Gather metadata about the instance.
metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
instance_id = Net::HTTP.get(URI.parse(metadata_endpoint + 'instance-id'))
instance_region = Net::HTTP.get(URI.parse(metadata_endpoint + 'placement/availability-zone'))
instance_region = instance_region[0...-1]

hostname = nil
zone_id = nil
priv_dns = nil

# It's a little boxy thing, Norm. With switches on it? Lets my computer talk to the one there.
client = Aws::EC2::Client.new(region: "#{instance_region}")

# Get info about the instance.
resp_data = client.describe_instances(
  instance_ids: ["#{instance_id}"]
)

resp_data.reservations.each do |res|
  res.instances.each do |inst|
    # Get the instance's tags to use in the hostname.
    tags = {}
    inst.tags.each do |tag|
      tags[tag.key] = tag.value

      name = tags['Name']
      app = tags['app'] || 'noapp'
      type = tags['type'] || 'notype'
      env = tags['env'] || 'noenv'

      # Get the instance's private DNS name to use in the hostname.
      priv_dns = inst.private_dns_name
      priv_dns_short = inst.private_dns_name.chomp('.ec2.internal')

      hostname = name || "#{app}-#{type}-#{env}-#{priv_dns_short}"
    end

    # Now use the hostname as the AWS instance name.
    resp_sethostname = client.create_tags(
     resources: ["#{instance_id}"],
     tags: [
       {
         key: 'Name',
         value: "#{hostname}"
       }
     ]
    )

    # Figure out which DNS zone to use.
    prefix = 'us-'
    dns_zone = instance_region
    dns_zone.slice! prefix

    domain = "#{dns_zone}.#{fqdn}"

    # Set the hostname locally.
    system "hostname #{hostname}"
    system "echo #{hostname} > /etc/hostname"
    system "cat<<EOF > /etc/hosts
# This file is automatically genreated by the set_hostname.rb script
127.0.0.1 #{hostname}.#{domain} #{hostname} localhost localhost.#{domain}

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF"

    # Now let's have a chat with Route53.
    route53 = Aws::Route53::Client.new(
      region: "#{instance_region}"
    )

    # What's the Zone ID for our domain?
    resp_zone = route53.list_hosted_zones_by_name(
      dns_name: "#{domain}",
      max_items: 1
    )

    resp_zone.hosted_zones.each do |zone|
      zone_id = zone.id
      prefix = '/hostedzone/'
      zone_id.slice! prefix
    end

    # Check to make sure a record set doesn't already exist for this instance.
    resp_checkrecords = route53.list_resource_record_sets(
      hosted_zone_id: "#{zone_id}",
      start_record_name: "#{hostname}.#{domain}.",
      max_items: 1
    )

    record_check = resp_checkrecords.resource_record_sets

    # Finally, create a new record set for this instance if one doesn't exist.
    if record_check.empty?
      resp_createrecord = route53.change_resource_record_sets(
        hosted_zone_id: "#{zone_id}",
        change_batch: {
          changes: [
            {
              action: 'CREATE',
              resource_record_set: {
                name: "#{hostname}.#{domain}",
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  {
                    value: "#{priv_dns}"
                  }
                ]
              }
            }
          ]
        }
      )
      puts 'Record created!'
    else
      puts 'Record exists!'
    end
  end
end
