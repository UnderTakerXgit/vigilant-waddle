--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

local APP = {} -- First we build the app object. Keep in mind that the APP object is never "reset".
-- So if you store things in it, those vars will be there forever. If you want a place to temp store stuff
-- that will be deleted each time the app is loaded, you can use a table within the APP object called
-- "garbage". "garbage" will be reset as soon as the app is opened
APP.garbage = {}

APP.UniqueName = "template" -- This is a unique name with no special characters or uppercase (Excluding _)
APP.Name = "Template" -- Give the app a display name
APP.ShowOnHUB = false -- Should the app show on the HUB?

-- This is called when the app is opened
function APP:Load()

end

-- This is called when the app is closed.
-- Note: It is not called on events like SWEP change or unexpected turn off. Only when the app is exited back into the HUB
function APP:Close()

end

-- Paint the thumbnail to be shown on the HUB (Not needed if not shown on HUB)
function APP:PaintThumbnail(x, y, w, h)
end

-- This is the function that is called while the app is open, and is shown "full screen". You should do all your
-- interface and logic here. This is basically the heart of the app.
function APP:Render(x, y, w, h)

end


return APP -- Returning the APP will have pCams auto register it.

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
