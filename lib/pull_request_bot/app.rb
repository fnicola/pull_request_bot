require 'httparty'
require 'json'
require "sinatra"

module PullRequestBot
  class App < Sinatra::Base

    def get_info response
      @body = response["comment"]["body"]
      @sender = response["comment"]["user"]["login"]
      if response["pull_request"]
        @url = response["pull_request"]["html_url"]
        @author = response["pull_request"]["user"]["login"]
      elsif response["issue"]
        @url = response["issue"]["pull_request"]["html_url"]
        @author = response ["issue"]["user"]["login"]
      end
    end

    def build_body
      auth_map = ENV["SLACK_MAPPING"]
      puts auth_map.inspect
      author_slack = auth_map[@author] || "#test_bot_nicola"
      body = { "pretext" => "#{@sender} added a comment on your <#{@url}|PR>",
               "channel" => "@#{author_slack}",
               "username" => "PR Review Cop",
               "icon_emoji" => ":cop:",
               "fields" =>[
                 {
                   "title"=>"#{@body}",
                   "value"=>"Please address the comment as soon as possible",
                   "short"=>true
                 }
               ]
      }
    end

    before do
      content_type 'application/json'
    end

    get '/' do
      {name: 'prb', version: '0.1'}.to_json
    end

    post '/payload' do
      puts "test logs"
      slack_webhook = ENV["SLACK_WEBHOOK"]
      puts slack_webhook.inspect
      response = JSON.parse(request.body.read)
      if response && response["action"] == "created"
        get_info(response)
        response = HTTParty.post slack_webhook, body: build_body.to_json
      end
    end
  end
end
