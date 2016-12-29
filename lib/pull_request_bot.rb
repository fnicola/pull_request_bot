require 'rubygems'
require 'bundler/setup'

Bundler.require

%w[
  app
].each do |file|
  require File.dirname(__FILE__) + "/pull_request_bot/#{file}"
end

module PullRequestBot
  class << self
  end
end

