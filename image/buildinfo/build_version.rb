require 'json'
require 'fileutils'
require 'optparse'
require 'securerandom'

class BuildVersion
  attr_accessor :options, :build_info_file

  def initialize(options)
    @build_info_file = 'buildInfo.json'
    @options = options
  end

  def execute
    file = File.open( @build_info_file, 'a+')
    json_object = JSON.load(file.read)

    # Object does not exist, so create it.
    if options.version.nil? && !options.image.nil?
      options.version = SecureRandom.uuid.gsub! '-', ''
    end

    build_date_time = Time.new.strftime '%Y-%m-%d_%H:%M:%S'
    if json_object.nil?
      json_object =  {:version => options.version, :buildTime => build_date_time, :imageId => options.image_id, :versions => {options.image => options.version} }
    else

      unless options.version.nil?
        json_object['version'] = options.version
        json_object['versions'][options.image] = options.version
        json_object['buildTime'] = build_date_time
      end

      unless  options.image_id.nil?
        json_object['imageId'] = options.image_id
        json_object['buildTime'] = build_date_time
      end
    end
    file.close

    file = File.open( @build_info_file, 'w')
    file.write(json_object.to_json.to_s)
    file.close
  end
end

# Parse Command Line Options
#
options = OpenStruct.new

opt_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: build_version.rb [options]'

  opts.on('--image=IMAGE_NAME', String, 'Image name for this build') do |image|
    options.image = image
  end

  opts.on('--version=VERSION', String, 'Version for this build, if none given then a random UUID will be generated.') do |version|
    options.version = version
  end

  opts.on('--imageid=IMAGE_ID', String, 'Image ID for a given docker file.') do |image_id|
    options.image_id = image_id
  end
end
opt_parser.parse!

# Check to see if we have valid inputs:

# If we have a "version" then we need to have an Image
#
if options.version && options.image.nil?
  puts 'ERROR: For a version you have to have a image name'
  puts opt_parser.to_s
else
  # You need to pass at lest an image_id or image name
  #
  if options.image_id.nil? && options.image.nil?
    puts 'ERROR: You need to pass at lest an image_id or image name'
    puts opt_parser.to_s
  else
    version = BuildVersion.new(options)

    if !options.image_id.nil? && !File.exist?(version.build_info_file)
      puts 'ERROR: Need to create a build info using image name and version first, before you try and just set the image_id'
      puts opt_parser.to_s
    else
      # Just do it!
      version.execute
    end

  end
end

