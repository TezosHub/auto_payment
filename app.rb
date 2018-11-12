require 'sinatra'
require './config.rb'
port = ARGV[0]
set :bind, '0.0.0.0'
set :port, port
set :root, File.dirname(__FILE__)
set :public_folder, Proc.new { File.join(root, "static") }
set :views, Proc.new { File.join(root, "view") }
get '/' do
    @title = "tezos 批量打款"

    if !File::exists?config[:transferFile]
        # 文件不存在
        text = File.read("transfer.json")
        File.open(config[:transferFile],"w+") do |file|
            file.puts text
        end
    end

    if !File::exists?config[:bakingUserFile]
        # 文件不存在
        text = File.read("bakingUser.json")
        File.open(config[:bakingUserFile],"w+") do |file|
            file.puts text
        end
    end

    if !File::exists?config[:publicKeysFile]
        # 文件不存在
        text = []
        text << {
            :name => "alice",
            :value => {
              :locator => "unencrypted:edpkvJgayg1PDSC8PQhYHR2vC2QXfKkRrQe8BboAN9nU8ssNdARzWe",
              :key => "edpkvJgayg1PDSC8PQhYHR2vC2QXfKkRrQe8BboAN9nU8ssNdARzWe"
            } 
          }
        text_json = JSON text
        File.open(config[:publicKeysFile],"w+") do |file|
            file.puts text_json
        end
    end


    users = File.read(config[:bakingUserFile])
    usersJson = JSON.parse(users)
    @bakingUser = {
        :name => usersJson["name"], 
        :address => usersJson["address"]
    }

    users = File.read(config[:transferFile])
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


get '/reset' do
    text = File.read("transfer.json")
    File.open(config[:transferFile],"w+") do |file|
        file.puts text
    end

    text = File.read("bakingUser.json")
    File.open(config[:bakingUserFile],"w+") do |file|
        file.puts text
    end
    redirect "/"
end

get '/edit/transfer' do
    @title = "tezos 批量打款"
    users = File.read(config[:transferFile])
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
    @item = json.to_json
    erb :edit
end


post '/edit/transfer' do
    text = params["text"]

    File.open(config[:transferFile],"w+") do |file|
        file.puts text
    end
    redirect "/"
end

get '/edit/bakingUser' do
    @title = "tezos 批量打款"
    users = File.read(config[:bakingUserFile])
    usersJson = JSON.parse(users)
    json = {
        :name => usersJson["name"], 
        :address => usersJson["address"]
    }
    @item = json.to_json
    erb :edit
end


post '/edit/bakingUser' do
    text = params["text"]

    File.open(config[:bakingUserFile],"w+") do |file|
        file.puts text
    end
    redirect "/"
end


get '/test' do
    config[:transferFile]
end

get '/download/transfer' do
    headers \
        "Content-Disposition" => "attachment;filename=transfer.json"
    send_file config[:transferFile]
end

get '/download/bakingUser' do
    headers \
        "Content-Disposition" => "attachment;filename=transfer.json"
    send_file config[:bakingUserFile]
end

get '/payment' do
    @title = "tezos 批量打款"
    json = []

    # 读取面包师的json文件，加入配置项。

    bakingUser = File.read(config[:bakingUserFile])
    bakingUserJson = JSON.parse(bakingUser)
    json << {:name => bakingUserJson["name"], :value => bakingUserJson["address"]}

    # 读取需要分红的委托用户json文件，这个需要后台调用api生成，加入到配置项。

    users = File.read(config[:transferFile])
    usersJson = JSON.parse(users)
    usersJson.each do |user|
        userJson = {:name => user["name"], :value => user["address"]}
        json << userJson
    end

    # 配置项生成配置文件
    json = JSON json
    public_key_hashs = json
    
    File.open(config[:publicKeyHashsFile],"w+") do |file|
        file.puts(json)
    end



    # 生成批量转账脚本

    @index = 0
    File.open(config[:autoBashFile],"w+") do |file|
        usersJson.each do |user|
            @index += 1
            bakingUser = bakingUserJson["name"]
            userName = user["name"]
            amount = user["amount"]
            file.puts("echo transfer #{@index} :from #{bakingUser} to #{userName}  pay #{amount} fee 0.05;")
            file.puts("echo  ;")
            file.puts("tezos-client transfer #{amount} from #{bakingUser} to #{userName} --fee 0.05;")
            file.puts("echo  ;")
            file.puts("echo  ;")
        end
    end

    # 执行批量转账脚本
    @out_text = ""
    exefile = config[:autoBashFile]
    IO.popen("sh #{exefile}") do |f|
        begin
        line = f.gets
        puts "\n#{line}"
        @out_text += "#{line}"
        end while line!=nil
    end
    @out_text
end