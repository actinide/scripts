#!/usr/bin/ruby

require 'aws-sdk'
require 'getoptlong'
require 'net/https'
require 'rubygems'

ref_num = Time.now.utc
ref_num = ref_num.strftime("%d%b%Y%H%M%S%Z")

# Path only accepts one argument for now
opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--distid', '-d', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--path', '-p', GetoptLong::REQUIRED_ARGUMENT ],
)

cf_dist = nil
cf_path = nil

opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF


    USAGE: clearcache.rb [OPTIONS]

        -h, --help:
        Show help

        -d, --distid:
        CloudFront distribution ID

        -p, --path:
        Invalidation path (usually /*)

    EOF
  when '--distid'
    cf_dist = arg
  when '--path'
    cf_path = arg
  end
end

if ARGV[0] =~ /\-help/
  puts "Missing required options! Try --help"
  exit 0
end

cloudfront = Aws::CloudFront::Client.new(region: "us-east-1")

resp = cloudfront.create_invalidation(
  distribution_id: "#{cf_dist}",
  invalidation_batch: {
    paths: {
      quantity: 1,
      items: [ "#{cf_path}" ],
    },
    caller_reference: "#{ref_num}",
  },
)
