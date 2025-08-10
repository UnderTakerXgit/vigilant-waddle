PawsUI = {}

PawsUI.Theme = {
    Background = Color(53, 59, 72),
    Primary = Color(47, 54, 64),

    DarkGray = Color(47, 54, 64),
    Gray = Color(113, 128, 147), 

    DarkBlue = Color(64, 115, 158),
    Blue = Color(0, 151, 230),
    
    ScrollBlue = Color(39, 60, 117),
    ScrollDarkBlue = Color(25, 42, 86),

    Red = Color(194, 54, 22),
    LightRed = Color(232, 65, 24),

    Text = Color(220, 221, 225),
    HoveredText = Color(245, 246, 250),

    Green = Color(76, 209, 55),
    DarkGreen = Color(68, 189, 50),

    Gold = Color(225, 177, 44),
    Yellow = Color(251, 197, 49),

    AlphaWhite = Color(220, 221, 225, 50)
}

PawsUI.Materials = {
    CloseButton = 'https://i.imgur.com/uSqgmuD.png',
    SettingsButton = 'https://i.imgur.com/5em8djK.png'
}

PawsUI.TransitionTime = .15

for k, v in pairs(PawsUI.Materials) do
    local path = 'pawsui/downloads/'..string.lower(k)..'.png'
	local dPath = 'data/'..path

	if(file.Exists(path, 'DATA')) then PawsUI.Materials[k] = Material(dPath, 'smooth noclamp') end
	if(!file.IsDir(string.GetPathFromFilename(path), 'DATA')) then file.CreateDir(string.GetPathFromFilename(path)) end


	http.Fetch(v, function(body, size, headers, code)
		if(code != 200) then return errorCallback(code) end
		file.Write(path, body)
		PawsUI.Materials[k] = Material(dPath, 'smooth noclamp')
        
	end)
end

