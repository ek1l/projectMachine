require 'sinatra/base'
require 'securerandom'
require 'sinatra/contrib/all'
require 'base64'


class SuperSecret < Sinatra::Base
  set :public_folder, File.join(File.dirname(__FILE__), 'public')
  set :views, File.join(File.dirname(__FILE__), 'views')
  register Sinatra::Contrib

  def sign(str)
    digest = Digest::SHA256.hexdigest(ENV['SECRET']+str) 
  end

  helpers do
    alias_method :h, :escape_html
  end
  
  get '/' do
    @code_sig = sign("server.rb")
    return erb :index
  end 

  get '/getfile' do
    @filename = params['filename']
    puts @filename
    puts @filename.inspect
    if @filename.empty?
      return 401 
    end
    if sign(@filename) == params['signature']
      @filename.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') 
      @filename.gsub!(/[^\w\/.]/,'')
      content_type :text
      return File.read(File.basename(@filename))
    else 
      return 401
    end
  end 
end
SuperSecret.run! if __FILE__ == $0

# Folder architecture:
# .
# ├── Gemfile
# ├── Gemfile.lock
# ├── db_config.yml
# ├── server.rb
# └── views
#     └── index.erb
#
