require 'sinatra'
require './config.rb'
require './keysHelper.rb'
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
        init_transfer
    end

    if !File::exists?config[:bakingUserFile]
        # 文件不存在
        init_baking_user
    end

    if !File::exists?config[:public_key_hashs]
        # 文件不存在
        make_public_keys_hash
    end

    bakingUser = File.read(config[:bakingUserFile])
    @bakingUser = JSON bakingUser
    transfer = File.read(config[:transferFile])
    @items = JSON transfer
    @addresses = public_key_hashs 
    erb :index
end


get '/reset' do
    init_baking_user
    init_transfer
    redirect "/"
end

get '/edit/transfer' do
    @title = "tezos 批量打款"
    users = File.read(config[:transferFile])
    # usersJson = JSON.parse(users)
    @item = (JSON users).to_json
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
    item = JSON.parse(users)
    @item = item.to_json
    erb :edit
end


post '/edit/bakingUser' do
    text = params["text"]
    File.open(config[:bakingUserFile],"w+") do |file|
        file.puts text
    end
    redirect "/"
end

get '/edit/public_key_hashs' do
    @item = public_key_hashs.to_json
    erb :edit
end

post '/edit/public_key_hashs' do
    text = params["text"]
    save_public_key_hashs(text)
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
        "Content-Disposition" => "attachment;filename=bakingUser.json"
    send_file config[:bakingUserFile]
end

get '/download/public_key_hashs' do
    headers \
        "Content-Disposition" => "attachment;filename=public_key_hashs"
    send_file config[:public_key_hashs]
end



# 转账前操作
get '/make_keys' do
    make_keys
end

# 转账后操作
get '/clear_keys' do
    clear_keys
end

get '/payment/:user/:amount/:fee' do
   
    Time.now.to_i
end

post '/payment' do

    name = params["name"]
    time = Time.now.to_i

    pay_name = "name_#{time}"
    pay_address = params["address"]
    pay_amount = params["amount"]
    pay_fee = params["fee"]

    @title = "tezos 批量打款"
    
    # # 生成批量转账脚本
    # @index = 0
    # File.open(config[:autoBashFile],"w+") do |file|
    #     usersJson.each do |user|
    #         @index += 1
    #         bakingUser = bakingUserJson["name"]
    #         userName = user["name"]
    #         amount = user["amount"]
    #         file.puts("echo transfer #{@index} :from #{bakingUser} to #{userName}  pay #{amount} fee 0.05;")
    #         file.puts("echo  ;")
    #         file.puts("tezos-client transfer #{amount} from #{bakingUser} to #{userName} --fee 0.05;")
    #         file.puts("echo  ;")
    #         file.puts("echo  ;")
    #     end
    # end

    # # 执行批量转账脚本
    # @out_text = ""
    # exefile = config[:autoBashFile]
    # IO.popen("sh #{exefile}") do |f|
    #     begin
    #     line = f.gets
    #     puts "\n#{line}"
    #     @out_text += "#{line}"
    #     end while line!=nil
    # end
    # @out_text
    "#{time}"
end

get '/state/:id' do
    "ok"
end