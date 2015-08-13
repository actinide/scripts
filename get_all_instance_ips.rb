#!/usr/bin/env ruby

require 'aws-sdk'
require 'rubygems'

time = Time.now.utc
time = time.strftime('%d%b%Y%H%M%S%Z')

instance_ips = []
instance_names = []

inv_file = File.open("inventory_#{time}", 'w')
scan_file = File.open("scan_file_#{time}", 'w')

client = Aws::EC2::Client.new(region: 'us-east-1')

# Get a list of available regions
region_list = client.describe_regions

# Get the name of each region
region_list.regions.each do |regions|
  region_name = regions.region_name

  # Get a list of instances running in each region
  ec2 = Aws::EC2::Client.new(region: "#{region_name}")
  instance_list = ec2.describe_instances(
    filters: [
      {
        name: 'instance-state-name',
        values: %w(pending running)
      }
    ]
  )

  # Get the name and IP of each instance
  instance_list.reservations.each do |instance|
    instance.instances.each do |inst_attr|
      instance_ip = inst_attr.public_ip_address
      instance_tags = inst_attr.tags

      instance_ips << instance_ip
      instance_names << instance_tags
    end
  end
end

# Write the instance IPs and names to inventory files for later use
inv_file.puts instance_ips
inv_file.puts instance_names
scan_file.puts instance_ips
