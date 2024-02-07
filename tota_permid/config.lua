Config = Config or {}

Config.LicenseCollumName = 'identifier' -- Name of the collum in your users table wich has as a value the user identifier. eg: char1:18945dc460f99c30c983518ecc14n98h49eg972, license:18945dc460f99c30c983518ecc14n98h49eg972
Config.Marker = false -- True to show Marker Above Head while talking, False not to show it.
Config.Command = "displayid" -- Personalize your "show ID" command. You can attach it to a key, but I recommend to have it as a command.
Config.MaxNumber = 20000 -- Max number of Permanent IDs given. I recomend to keep this number as high as possible to avoid collisions.
Config.Debug = true -- Keep this flase if you dont want your console flooded with messages.
Config.ServerName = 'Tota Network' -- The name of your server.
Config.KickedMessage = 'You have been kicked from ' .. Config.ServerName .. '.' -- Message that will show if a player gets kicked.