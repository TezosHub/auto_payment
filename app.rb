require 'sinatra'
port = ARGV[0]
set :bind, '0.0.0.0'
set :port, port
set :root, File.dirname(__FILE__)
set :public_folder, Proc.new { File.join(root, "static") }
set :views, Proc.new { File.join(root, "view") }
get '/' do
    @title = "tezos 批量打款"
    users = File.read('transfer.json')
    json = []
    usersJson = JSON.parse(users)
    usersJson.each do |user|
        userJson = {
            :name => user["name"], 
            :address => user["address"],
            :amount => user["amount"]
        }
        json << userJson
    end
    @items = json
    erb :index
end


get '/edit/transfer' do
    erb :edit
end

get '/download/transfer' do
    headers \
        "Content-Disposition" => "attachment;filename=transfer.json"
    send_file "transfer.json"
end

get '/download/bakingUser' do
    headers \
        "Content-Disposition" => "attachment;filename=transfer.json"
    send_file "bakingUser.json"
end

get '/payment' do
    @title = "tezos 批量打款"
    users = File.read('transfer.json')
    json = []
    usersJson = JSON.parse(users)
    usersJson.each do |user|
        userJson = {
            :name => user["name"], 
            :address => user["address"],
            :amount => user["amount"]
        }
        json << userJson
    end
    @items = json
    erb :index
end