#!/opt/chef/embedded/bin/ruby
#
# Modified from https://gist.github.com/stormerider/5600427

require 'aws-sdk'
require 'chef'
require 'rubygems'

aws_account_name = ''
knife_config_path = '/etc/cron.scripts/knife.rb'

# Set up Chef config
Chef::Config.from_file(knife_config_path)

# Set up some EC2 stuff
ec2_regions = ['us-east-1', 'us-west-1', 'us-west-2']
ec2_instances = []

# Check what's running in AWS
puts 'Checking account: ' + aws_account_name

ec2_regions.each do |ec2_region|
  # Set up region-specific clients
  ec2 = Aws::EC2::Client.new(region: ec2_region)

  # List all of our running instances
  resp = ec2.describe_instances(
    dry_run: false,
    filters: [
      {
        name: 'instance-state-name',
        values: ['pending', 'running', 'shutting-down', 'stopping', 'stopped']
      }
    ]
  )

  resp.reservations.each do |reservation|
    reservation.instances.each do |instance|
      ec2_instance = instance[:instance_id]
      puts "#{ec2_instance} exists in AWS"
      ec2_instances << ec2_instance
    end
  end
end

  # Get a list of all our Chef nodes
  chef_nodes = []
  Chef::Search::Query.new.search(:node, 'ec2_instance_id:i-*') do |node|
    chef_node = (node['ec2']['instance_id'])
    puts "#{chef_node} exists in Chef"
    chef_nodes << chef_node
  end

  # Compile a list of nodes that exist in Chef but have no corresponding instance
  stale_nodes = chef_nodes - ec2_instances

  # Delete the stale clients and nodes
  stale_nodes.each do |stale_node|
    Chef::Search::Query.new.search(:node, "ec2_instance_id:#{stale_node}") do |dead_node|
    node_name = dead_node.name
    puts "Detected stale node #{node_name}"
    client_begone = Chef::ApiClient.load(node_name)
    client_removed = client_begone.destroy
    puts "Removed stale client #{client_removed}"
    node_begone = Chef::Node.load(node_name)
    node_removed = node_begone.destroy
    puts "Removed stale node #{node_removed}"
  end
end
