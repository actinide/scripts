#!/usr/bin/env ruby

require 'aws-sdk'
require 'net/https'
require 'rubygems'

# Gather metadata about the instance
metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
instance_id = Net::HTTP.get(URI.parse(metadata_endpoint + 'instance-id'))
instance_region = Net::HTTP.get(URI.parse(metadata_endpoint + 'placement/availability-zone'))
instance_region = instance_region[0...-1]

# It's a little boxy thing, Norm. With switches on it? Lets my computer talk to the one there.
client = Aws::EC2::Client.new(region: "#{instance_region}")

# Get info about the instance
resp_data = client.describe_instances(
  instance_ids: ["#{instance_id}"]
)

resp_data.reservations.each do |res|
  res.instances.each do |inst|
    # Get the instance's tags to use in the hostname
    tags = {}
    inst.tags.each do |tag|
      tags[tag.key] = tag.value

      name = tags['Name'] || 'noname'
      app = tags['app'] || 'noapp'
      type = tags['type'] || 'notype'
      env = tags['env'] || 'noenv'

    # Get the instance's private DNS name to use in the hostname
    priv_dns_name = inst.private_dns_name.chomp('.ec2.internal')

    hostname = "#{app}-#{type}-#{env}-#{priv_dns_name}"

      # Use the hostname as the AWS instance name
      resp_sethostname = client.create_tags(
       resources: ["#{instance_id}"],
       tags: [
         {
           key: 'Name',
           value: "#{hostname}"
         }
       ]
      )


    end
  end
end
