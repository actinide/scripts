#!/usr/bin/ruby

require 'aws-sdk'
require 'net/https'
require 'rubygems'

time = Time.now.utc
time = time.strftime("%d%b%Y%H%M%S%Z")

# Gather metadata about the instance
metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
instance_id = Net::HTTP.get( URI.parse( metadata_endpoint + 'instance-id' ) )
instance_region = Net::HTTP.get( URI.parse( metadata_endpoint + 'placement/availability-zone' ) )
instance_region = instance_region[0...-1]

puts instance_id
puts instance_region

# It's a little boxy thing, Norm. With switches on it? Lets my computer talk to the one there.
client = Aws::EC2::Client.new(region: "#{instance_region}")

# Get the instance name to use in the image name
resp = client.describe_tags({
  dry_run: false,
  filters: [
    {
      name: "resource-id",
      values: ["#{instance_id}"],
    },
    {
      name: "resource-type",
      values: ["instance"],
    },
    {
      name: "key",
      values: ["Name"],
    },
  ],
})

instance_name = resp.tags[0].value
puts instance_name

# And finally, image the instance
resp = client.create_image({
  dry_run: true,
  instance_id: "#{instance_id}", # Required
  name: "#{instance_name}-#{time}", # required
  description: "Pre-patch backup of #{instance_name}",
  no_reboot: true,
})
