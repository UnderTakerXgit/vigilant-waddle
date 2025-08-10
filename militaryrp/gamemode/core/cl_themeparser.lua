--[[
Server Name: Hero of the Republic SWRP | Clone Wars v1.04
Server IP:   45.136.204.90:27015
File Path:   gamemodes/starwarsrp/gamemode/core/cl_themeparser.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

hook.Add('NextRP::ModulesLoaded', 'NextRP::ThemeParser', function()
	for k, v in pairs(NextRP.Style.Materials) do
		local path = 'nextrp/theme/'..NextRP.ServerID..'_'..NextRP.Style.ID..'/'..string.lower(k)..'.png'
		local dPath = 'data/'..path
	
		if(file.Exists(path, 'DATA')) then NextRP.Style.Materials[k] = Material(dPath, 'mips smooth') end
		if(!file.IsDir(string.GetPathFromFilename(path), 'DATA')) then file.CreateDir(string.GetPathFromFilename(path)) end
	
		http.Fetch(v, function(body, size, headers, code)
			if(code != 200) then return errorCallback(code) end
			file.Write(path, body)
			NextRP.Style.Materials[k] = Material(dPath, 'mips smooth')
		end)
	end

	hook.Call('NextRP::IconLoaded', GM)
end)