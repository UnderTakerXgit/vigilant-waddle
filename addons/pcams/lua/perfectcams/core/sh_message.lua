--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

if SERVER then
    function PerfectCams.Core.Msg(ply, msg)
        if (!IsValid(ply)) then return end
        
        net.Start("pCams:Msg")
            net.WriteString(msg)
        net.Send(ply)
    end
else
    net.Receive("pCams:Msg", function()
        PerfectCams.Core.Msg(net.ReadString())
    end)
    function PerfectCams.Core.Msg(msg)
        chat.AddText(PerfectCams.Config.PrefixColor, PerfectCams.Config.Prefix .. ' ', color_white, msg)
    end
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
