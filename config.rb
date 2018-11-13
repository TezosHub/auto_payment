def config
    rootDir = "/home/pm"
    {
        :bakingUserFile => "./data/bakingUser.json",
        :transferFile => "./data/transfer.json",
        :public_key_hashs => "#{rootDir}/.tezos-client/public_key_hashs",
        :public_keys => "#{rootDir}/.tezos-client/public_keys",
        :secret_keys => "#{rootDir}/.tezos-client/secret_keys",
        :autoBashFile => "#{rootDir}/.tezos-client/auto.sh"
    }
end