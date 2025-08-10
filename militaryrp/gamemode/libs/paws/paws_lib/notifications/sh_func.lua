local MODULE = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

// MODULE:Notify(text, icon, duration, progressColor, textColor)

function MODULE:SendNotify(ply, text, icon, duration, progressColor, textColor)
    local args = {
        text = text or 'Нет текста... Простите! ;)',
        icon = icon or 0,
        duration = duration or 4,
        progressColor = progressColor or Colors.ButtonHover,
        textColor = textColor or Colors.Text
    }
    args = util.Compress(util.TableToJSON(args))
    
    if SERVER then
        net.Start('Paws.Lib.Notify')
            net.WriteData(args, 255)
        net.Send(ply)
    end
    
    if CLIENT then
        net.Start('Paws.Lib.Notify')
            net.WriteEntity(ply)
            net.WriteData(args, 255)
        net.SendToServer()
    end
end

local pMeta = FindMetaTable('Player')

function pMeta:SendNotification(text, icon, duration, progressColor, textColor)
    MODULE:SendNotify(self, text, icon, duration, progressColor, textColor)
end