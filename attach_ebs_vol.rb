#!/usr/bin/ruby

require 'aws-sdk'
require 'net/https'
require 'rubygems'

volume = " " # Static ID for now

metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
instance_id = Net::HTTP.get( URI.parse( metadata_endpoint + 'instance-id' ) )

ec2 = Aws::EC2::Client.new(region: 'us-east-1')

ec2.attach_volume(
  dry_run: false, # Change this to true to test the script
  volume_id: "#{volume}",
  instance_id: instance_id,
  device: "xvdm"
)
