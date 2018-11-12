#!/usr/bin/ruby

require "pp"
require "json"

json = []

# 读取面包师的json文件，加入配置项。

bakingUser = File.read('bakingUser.json')
bakingUserJson = JSON.parse(bakingUser)
json << {:name => bakingUserJson["name"], :value => bakingUserJson["address"]}

# 读取需要分红的委托用户json文件，这个需要后台调用api生成，加入到配置项。

users = File.read('transfer.json')
usersJson = JSON.parse(users)
usersJson.each do |user|
	userJson = {:name => user["name"], :value => user["address"]}
	json << userJson
end

# 配置项生成配置文件
json = JSON json
public_key_hashs = json
pp json

File.open("public_key_hashs","w+") do |file|
	file.puts(json)
end

# 生成批量转账脚本

@index = 0
File.open("auto.sh","w+") do |file|
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
IO.popen("sh auto.sh") do |f|
	begin
	line = f.gets
	puts "\n#{line}"
	end while line!=nil
end
