def make_public_keys
    text = File.read("./config/bakingUser.json")
    bakingUserJson = JSON.parse(text)
    name = bakingUserJson["name"]
    publicKey = bakingUserJson["public"]

    text = []
    text << {
        :name => "#{name}",
        :value => {
            :locator => "unencrypted:#{publicKey}",
            :key => "#{publicKey}"
        } 
    }
    text_json = JSON text
    File.open(config[:public_keys],"w+") do |file|
        file.puts text_json
    end
end

def make_public_keys_hash
    # 读取面包师的json文件，加入配置项。
    json = []
    bakingUser = File.read(config[:bakingUserFile])
    bakingUserJson = JSON.parse(bakingUser)
    json << {:name => bakingUserJson["name"], :value => bakingUserJson["address"]}

    # 支付时往里添加

    # 读取需要分红的委托用户json文件，这个需要后台调用api生成，加入到配置项。
    # users = File.read(config[:transferFile])
    # usersJson = JSON.parse(users)
    # usersJson.each do |user|
    #     userJson = {:name => user["name"], :value => user["address"]}
    #     json << userJson
    # end

    # 配置项生成配置文件
    json = JSON json
    public_key_hashs = json
    
    File.open(config[:public_key_hashs],"w+") do |file|
        file.puts(json)
    end
end

def make_secret_keys
    text = File.read("./config/bakingUser.json")
    bakingUserJson = JSON.parse(text)
    name = bakingUserJson["name"]
    privateKey = bakingUserJson["private"]
    json = []
    json << {
        :name => "#{name}", 
        :value => "unencrypted:#{privateKey}"
    }
    text_json = JSON json
    File.open(config[:secret_keys],"w+") do |file|
        file.puts text_json
    end
end

def make_keys
    #生成地址配置  地址配置由支付时追加
    #make_public_keys_hash
    #生成公钥
    make_public_keys
    #生成私钥
    make_secret_keys
end

def clear_keys
    #File.delete(config[:public_key_hashs])
    File.delete(config[:public_keys])
    File.delete(config[:secret_keys])
end

# 初始化默认烘焙师配置
def init_baking_user
    text = File.read("./config/bakingUser.json")
    File.open(config[:bakingUserFile],"w+") do |file|
        file.puts text
    end  
end

# 初始化默认转账条目
def init_transfer
    text = File.read("./config/transfer.json")
    File.open(config[:transferFile],"w+") do |file|
        file.puts text
    end
end

def public_key_hashs
    JSON File.read(config[:public_key_hashs])
end

def save_public_key_hashs(text)
    File.open(config[:public_key_hashs],"w+") do |file|
        file.puts text
    end
end