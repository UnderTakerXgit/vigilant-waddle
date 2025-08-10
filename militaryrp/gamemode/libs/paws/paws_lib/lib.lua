local MODULE = PAW_MODULE('lib')
    :SetTitle('Lib')
    :SetAuthor('LOX')
    :SetVersion('Dev Branch')
    :SetRoot('paws_lib')
    :SetConfig('config.lua')
    :SetFileSystem({
        'chat',
        'commands',
        'download',
        'vgui',
        'elements',
        'notifications'
    })
    :SetNets({
        'Paws.Lib.Msg',
        'Paws.Lib.Notify'
    })

return MODULE 
-- Leak by VoLVeR https://vk.com/darkrp_credorp