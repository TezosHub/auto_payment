def config
    rootDir = "/home/pm"
    {
        :bakingUserFile => "#{rootDir}/.tezos-client/bakingUser.json",
        :transferFile => "#{rootDir}/.tezos-client/transfer.json",
        :publicKeyHashsFile => "#{rootDir}/.tezos-client/public_key_hashs",
        :autoBashFile => "#{rootDir}/.tezos-client/auto.sh"
    }
end