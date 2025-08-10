local MODULE = PAW_MODULE('lib')

// MODULE:Notify(text, icon, duration, progressColor, textColor)
net.Receive('Paws.Lib.Notify', function()
    local args = net.ReadData(255)
    args = util.JSONToTable(util.Decompress(args))
    print(args.icon)
    MODULE:Notify(args.text, args.icon, args.duration, args.progressColor, args.textColor)
end)