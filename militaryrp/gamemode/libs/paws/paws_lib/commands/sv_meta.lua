local MODULE = PAW_MODULE('lib')

local meta = {}
function meta.__call( self, var )
	return self
end 

local m = {
    command = 'newcommand',
    Title = 'New Command',
    Description = 'New Command Description',

    Run = function(self, pPlayer, sText)
        -- To edit
    end,

    OnRun = function(self, pPlayer, sText)
        self.Run(pPlayer, sText)
        hook.Run('Paws.Lib.CommandRun', self.command, pPlayer, sText)
    end,

    SetCommand = function(self, sString)
        self.command = sString
        return self
    end,
    SetTitle = function(self, sString)
        self.Title = sString
        return self
    end,
    SetDescription = function(self, sString)
        self.Description = sString
        return self
    end,

    SetOnRunFunction = function(self, fFuntion)
        self.Run = fFuntion
        return self
    end
}

meta.__index = m

function MODULE:Command(command, get)

    get = get or false

    self.Commands = self.Commands or {} // MODULE.Commands = MODULE.Comands or {}
    
    for k, v in ipairs(self.Commands) do
        if v.command == command then return self.Commands[k] end
    end

    if get then
        return nil
    end

    local CommandTable = {
        command = command or nil
    }

    setmetatable(CommandTable, meta)

    local i = table.insert(self.Commands, CommandTable)

    return self.Commands[i]
end

function NextRP:AddCommand(sCommand, fCallback)
    local cmd = MODULE:Command(sCommand, false)
    cmd:SetOnRunFunction(fCallback)
end