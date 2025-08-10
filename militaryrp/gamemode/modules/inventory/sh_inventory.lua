
-- sh_inventory.lua
function GM:SetupInventory(ply)
    ply.Inventory = {}

    for i = 1, 35 do
        ply.Inventory[i] = nil
    end
end

function GM:AddItem(ply, itemName)
    if not ply.Inventory then self:SetupInventory(ply) end

    for i = 1, 35 do
        if ply.Inventory[i] == nil then
            ply.Inventory[i] = { id = itemName, count = 1 }
            break
        end
    end
end


function GM:GetInventory(ply)
    if not ply.Inventory then
        self:SetupInventory(ply)
    end
    return ply.Inventory
end
