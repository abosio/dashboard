#! /usr/bin/env ruby
#
# Imports data from _data/private into _data/public.
#
# Expects to be run directly within the _data directory with the _data/private
# submodule present. All 'private:' data is stripped from the _data/private
# files before it is dumped into _data/public.
#
# Author: Mike Bland (michael.bland@gsa.gov)
# Date:   2014-12-22

require 'hash-joiner'
require 'safe_yaml'

PROJECT_FILES = Dir["private/projects/*.yml"]

private_projects_yaml_file = "private/projects.yml"
project_data = SafeYAML.load_file(private_projects_yaml_file, :safe=>true)
PROJECT_FILES.each do |source|
  data = SafeYAML.load_file(source, :safe=>true)
  unless data
    puts "Failed to parse #{source}"
    exit 1
  end
  data = data.first  # one project per yaml file in projects dir
  index = project_data.index { |proj| proj['name'] == data['name'] }
  index = project_data.length  if index.nil?
  project_data[index] = data
end
open(private_projects_yaml_file, 'w') {|outfile| outfile.puts project_data.to_yaml}


YAML_FILES = [
  'projects.yml',
]

YAML_FILES.each do |yaml_file|
  source = File.join('private', yaml_file)
  data = SafeYAML.load_file(source, :safe=>true)
  unless data
    puts "Failed to parse #{source}"
    exit 1
  end

  data = HashJoiner.remove_data data, 'private'
  puts "#{source} => #{yaml_file}"
  open(yaml_file, 'w') {|outfile| outfile.puts data.to_yaml}
end
