require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
enable :sessions
require 'pg'
client = PG::connect( :host => "localhost", :dbname => "satotogyo_homepage",)



get '/login' do 
    return erb :operate_login, :layout => :layout_login
end

post '/login' do 
    email = params[:email]
    password = params[:password]
    # puts "SQL Query: SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}'"
    user = client.exec_params("SELECT * FROM users WHERE email = $1 AND password = $2", [email, password]).to_a.first

    if user.nil?
        # puts "User is nil. Redirecting to operate_login."
        return erb :operate_login, :layout => :layout_login
    else
        # puts "User found. User info: #{user.inspect}"
        session[:user] = user
    end

     redirect "/operate_site"
end

delete '/logout' do 

    session[:user] = nil

    redirect "/login"
end

get '/operate_site' do 
    if session[:user].nil?
        redirect "/login"
    end

    

    return erb :operate_site, :layout => :layout_operatesite
end

get '/works_operate' do 
    if session[:user].nil?
        redirect "/login"
    end

    @contents = client.exec_params("SELECT * FROM works ORDER BY id ASC")

    return erb :works_operate, :layout => :layout_operatesite
end



post '/works_operate_new' do 
    
    title = params[:title] 
    
     image_path = ''

     if !params[:img].nil?
       tempfile = params[:img][:tempfile] 
       save_to = "./public/images/#{params[:img][:filename]}"
       FileUtils.mv(tempfile, save_to)
       image_path = params[:img][:filename]
     end

     client.exec_params("INSERT INTO works (img_path, title) VALUES ($1, $2)",[image_path, title])

     redirect "/works_operate"
end

post '/operate_works_edit' do
    id = params[:content_id]
    title = params[:title]
    file = params[:file]
    
    image_path = ''

    if !params[:file].nil?
       tempfile = params[:file][:tempfile] 
       save_to = "./public/images/#{params[:file][:filename]}"
       FileUtils.mv(tempfile, save_to)
       image_path = params[:file][:filename]
    end
    
    client.exec_params("UPDATE works SET title = $1, img_path = $2 WHERE id = $3", [title, image_path, id])
    
    
    
    redirect "/works_operate"
     
end

get '/exhibition_operate' do 

    if session[:user].nil?
        redirect "/login"
    end

    @exhibition = client.exec_params("SELECT * FROM exhibition ORDER BY id ASC")
    @exhibition2024 = client.exec_params("SELECT * FROM exhibition WHERE EXTRACT(YEAR FROM created_at) = 2024 ORDER BY id ASC")
    @exhibition2023 = client.exec_params("SELECT * FROM exhibition WHERE EXTRACT(YEAR FROM created_at) = 2023 ORDER BY id ASC")
    @exhibition

    return erb :exhibition_operate, :layout => :layout_operatesite
end

post '/exhibition_operate_new' do 
    title = params[:title]
    date = params[:date]
    image_path = ''

     if !params[:img].nil?
       tempfile = params[:img][:tempfile] 
       save_to = "./public/images/#{params[:img][:filename]}"
       FileUtils.mv(tempfile, save_to)
       image_path = params[:img][:filename]
     end

     client.exec_params("INSERT INTO exhibition (img_path, title, created_at) VALUES ($1, $2, $3)",[image_path, title, date])
     redirect "/exhibition_operate"
end

post '/operate_exhibition_edit' do
    date = params[:exhibition_date]
    title = params[:title]
    file = params[:file]
    
    image_path = ''

    if !params[:file].nil?
       tempfile = params[:file][:tempfile] 
       save_to = "./public/images/#{params[:file][:filename]}"
       FileUtils.mv(tempfile, save_to)
       image_path = params[:file][:filename]
    end
    
    client.exec_params("UPDATE exhibition SET title = $1, img_path = $2 WHERE date = $3", [title, image_path, date])
    
    
    
    redirect "/exhibition_oparate"
     
end

get '/toppage' do 
    @exhibition2024 = client.exec_params("SELECT * FROM exhibition WHERE EXTRACT(YEAR FROM created_at) = 2023 ORDER BY id ASC")
    return erb :index
end

get '/artist_page' do 
    return erb :artist
end

get '/works_page' do 
    @works = client.exec_params("SELECT * FROM works ORDER BY id ASC")
    return erb :works, :layout => :layout_works
end

get '/exhibition_page' do 

    @exhibition2024 = client.exec_params("SELECT * FROM exhibition WHERE EXTRACT(YEAR FROM created_at) = 2024 ORDER BY id ASC")
    @exhibition2023 = client.exec_params("SELECT * FROM exhibition WHERE EXTRACT(YEAR FROM created_at) = 2023 ORDER BY id ASC")

    return erb :exhibition
end

get '/contact_page' do 
    @contact = true
    return erb :contact
end

