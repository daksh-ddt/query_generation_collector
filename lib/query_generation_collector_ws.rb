#!/usr/bin/env ruby
require 'sinatra/base'
require 'rest_client'
require 'erb'
require 'json'

class QueryGenerationCollectorWS < Sinatra::Base
	configure do
		set :root, File.dirname(__FILE__).gsub(/lib/, '/')
		set :protection, :except => :frame_options
		set :server, 'thin'
	end

	before do
		query_generator_url = "http://110.45.246.131:5000/rest/query"
    @query_generator_ws = RestClient::Resource.new query_generator_url, :headers => {:content_type => :json, :accept => :json}

		graphfinder_wrapper_url = "http://110.45.246.131:38401/queries"
    @graphfinder_wrapper_ws = RestClient::Resource.new graphfinder_wrapper_url, :headers => {:content_type => :json, :accept => :json}

		@params = JSON.parse request.body.read, :symbolize_names => true if request.body && request.content_type && request.content_type.downcase == 'application/json'
	end

	get '/' do
		erb :index
	end

	post '/queries' do
		template = params[:template]
		disambiguation = params[:disambiguation]
		data = {template:template, disambiguation:disambiguation}

		qg_result = 
    @query_generator_ws.post data.to_json do |response, request, result|
      case response.code
      when 200
        JSON.parse response
      else
      	raise "Something wrong with query generator"
      end
    end

		gf_result = 
    @graphfinder_wrapper_ws.post data.to_json do |response, request, result|
      case response.code
      when 200
        JSON.parse response
      else
      	raise "Something wrong"
      end
    end

    results = qg_result + gf_result

		content_type :json
		results.to_json
	end

end
