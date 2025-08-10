netstream.Hook('NextRP::SaveCharAppereance', function(pPlayer, modelInfo)
    pPlayer:SetCharValue( 'model', util.TableToJSON(modelInfo), function()
        local c = pPlayer:CharacterByID(pPlayer:GetNVar('nrp_charid'))
        c.model = modelInfo
        if modelInfo.model and modelInfo.model then
            pPlayer:SetModel(modelInfo.model)
        end

        if modelInfo and modelInfo.skin then
            pPlayer:SetSkin(tonumber(modelInfo.skin))
        end

        if modelInfo and modelInfo.bodygroups then
            for k, v in pairs(modelInfo.bodygroups) do
                pPlayer:SetBodygroup(tonumber(k), tonumber(v))
            end
        end
    end )

end)