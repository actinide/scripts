#!/usr/bin/ruby

require 'aws-sdk'
require 'rubygems'

time = Time.now.utc
time = time.strftime('%d%b%Y%H%M%S%Z')

client = Aws::EC2::Client.new(region: 'us-east-1')

# Get a list of available regions
region_list = client.describe_regions

# Get the name of each region
region_list.regions.each do |region|
  region_name = region.region_name

  # Get a list of instances running in each region
  ec2 = Aws::EC2::Client.new(region: "#{region_name}")
  instance_list = ec2.describe_instances(
    filters: [
      {
        name: 'instance-state-name',
        values: ['pending', 'running']
      }
    ]
  )

  instance_list.reservations.each do |instance|
    instance_ip = instance.instances[0].public_ip_address
    instance_tags = instance.instances[0].tags
    puts instance_ip
    puts instance_tags
  end
end
