#!/usr/bin/env ruby
# share_schemes.rb

# Usage:
# Ex: running from project root
# ./scripts/share_schemes.rb -p "Carthage/Checkouts/agent-swift-XCTest/ReportPortalAgent.xcodeproj" -s "ReportPortalAgent" -u "<user_name>"

require 'optparse'
require 'ostruct'
require 'rubygems'
require 'xcodeproj'
require 'fileutils'

# Option parser
class OptionParser

    # Parse options
    # @param [Array<String>] args command line args
    # @return [OpenStruct] parsed options
    def self.parse(args)
        options = OpenStruct.new
        options.project = nil
        options.scheme_name = nil
        options.user = nil

        opt_parser = OptionParser.new do |opts|

            opts.banner = "Usage: #{File.basename($0)} [options]"

            opts.separator("")
            opts.on('-p [PROJECT]', '--project [PROJECT]', "Xcode project path. Automatically look up if not provided.") do |project|
                options.project = project
            end
            opts.on('-s [SCHEME_NAME]', '--scheme_name [SCHEME_NAME]', "Scheme name") do |scheme|
                options.scheme_name = scheme
            end
            opts.on('-u [USER]', '--user [USER]', "User scheme") do |user|
                options.user = user
            end
            opts.separator("")
            opts.separator("Help:")
            opts.on_tail('-h', '--help', 'Display this help') do
                puts opts
                exit
            end

        end

        opt_parser.parse!(args)
        options
    end # parse()
end

options = OptionParser.parse(ARGV)

# Lookup for Xcode project other than Pods
# @return [String] name of Xcode project or nil if not found
def lookup_project
    puts "Looking for Xcode project..."
    # list all .xcodeproj files except Pods
    projects_list = Dir.entries(".").select { |f| (f.end_with? ".xcodeproj") && (f != "Pods.xcodeproj") }
    projects_list.empty? ? nil : projects_list.first
end

# lookup if not specificed
options.project = lookup_project if !options.project
if !options.project then
    puts "Error".red.underline + ": No Xcode projects found in the working folder"
    exit 1
end

puts "Using project path: " + "#{options.project}".green

xcproj = Xcodeproj::Project.open(options.project)
xcproj.recreate_user_schemes
xcsch = Xcodeproj::XCScheme.share_scheme(options.project, options.scheme_name, options.user)

xcproj.save()
