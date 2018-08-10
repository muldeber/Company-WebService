require 'sinatra'
require "sinatra/namespace" #see gemfile for info
require "sinatra/cors"
require 'mongoid'

#db setup
Mongoid.load! "mongoid.yml"

#model
require './company' #must be after Bundler.require, as Company requires DataMapper

#serializer
require './companySerializer'

#credits to: https://github.com/jdesrosiers/sinatra-cors
#sets up and enables cross origin
	set :allow_origin, "*"
	set :allow_methods, "GET, DELETE, PUT, PATCH, HEAD, POST"
	set :allow_headers, "content-type,if-modified-since"
	set :expose_headers, "location,link"

#endpoints
get '/' do
	'Hej, her sker der ikke noget. Kaldene går gennem: /api/v1/companies'
	#headers['GET'] = "curl http://localhost:xxxx/api/v1/companies or curl http://localhost:xxxx/api/v1/companies/:id"
  #headers['POST'] = "curl -i -X POST -H 'Content-Type: application/json' -d '{'name':'xxx',...}' http://localhost:xxxx/api/v1/companies"
  #headers['DELETE'] = "curl -i -X DELETE -H 'Content-Type: application/json' http://localhost:xxxx/api/v1/companies/:id"
  #puts headers # show headers on this request
end

namespace '/api/v1' do
	before do
		content_type 'application/json'
	end

#helper methods
	helpers do
    def base_url
      @base_url ||= "http://localhost:4567"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message:'Invalid JSON' }.to_json
      end
    end
  end

	get '/companies' do
		companies = Company.all
#loop that goes through each scope. Defined in company.rb
		[:name, :cvr, :address].each do |filter|
			companies = companies.send(filter, params[filter]) if params[filter]
		end
#serializes the company object
		companies.map{|company| CompanySerializer.new(company)}.to_json
	end

	get '/companies/:id' do |id|
		company = Company.where(id:id).first
		halt(404, {message:'Company not found'}.to_json) unless company
		CompanySerializer.new(company).to_json
	end

	post '/companies' do
    company = Company.new(json_params)
    if company.save
      response.headers['Location'] = "#{base_url}/api/v1/companies/#{company.id}"
      status 201
    else
      status 422
      body CompanySerializer.new(company).to_json
    end
  end

#not working: No 'Access-Control-Allow-Origin' header is present on the requested resource
	put '/companies/:id' do |id|
    company = Company.where(id:id).first
    halt(404, {message:'Company not found'}.to_json) unless company
    if company.update_attributes(json_params)
      CompanySerializer.new(company).to_json
    else
      status 422
      body CompanySerializer.new(company).to_json
    end
  end

	delete '/companies/:id' do |id|
    company = Company.where(id:id).first
    company.destroy if company
    status 204
  end
end
