require 'sinatra/base'
require 'sys/proctable'
include Sys

class BuildInfo < Sinatra::Base

  #
  # Catch for page not found.
  #
  not_found do
    status 404
    "{'errorCode' : '404', 'error' : 'Page Not Found'}"
  end

  #
  # Find the process in the list
  #
  def find_process(name)
    ProcTable.ps{ |p|
      if p.comm.to_s == name
        return true
      end
    }
    false
  end

  #
  # Respond with Build Info
  #
  get '/buildinfo' do
    body File.read('/opt/buildInfo.json')
  end

  #
  #  Is process :name we "active"
  #
  get '/isActive/:name' do
    if find_process(params['name'])
      'SUCCESS'
    else
      'FAILURE'
    end
  end
end