#!/usr/bin/env ruby

require "json"
require "octokit"

json = File.read(ENV.fetch("GITHUB_EVENT_PATH"))
event = JSON.parse(json)

github = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

if !ENV["GITHUB_TOKEN"]
  puts "Missing GITHUB_TOKEN"
  exit(1)
end

if ARGV.empty?
  puts "Missing file path argument."
  exit(1)
end

repo = event["repository"]["full_name"]

if ["pull_request", "pull_request_target"].include? ENV.fetch("GITHUB_EVENT_NAME")
  pr_number = event["number"]
else
  pulls = github.pull_requests(repo, state: "open")

  push_head = event["after"]
  pr = pulls.find { |pr| pr["head"]["sha"] == push_head }

  if !pr
    puts "Couldn't find an open pull request for branch with head at #{push_head}."
    exit(1)
  end
  pr_number = pr["number"]
end

# if env INPUT_SOURCES is not defined then ARV[0] used as a source
# otherwise INPUT_SOURCES is assumed a JSON defining an array of strings (filenames)

puts Dir.entries(".")

if ARGV.length < 2
  sources = [ ARGV[0] ]
else
  sources = ARGV.drop(1)
end

message = sources.map{ | file_path | File.read(file_path) }.join("\n")

coms = github.issue_comments(repo, pr_number)

github.add_comment(repo, pr_number, message)
