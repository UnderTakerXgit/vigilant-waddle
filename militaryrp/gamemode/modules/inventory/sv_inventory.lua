util.AddNetworkString("OpenInventory")
util.AddNetworkString("InventoryData")
util.AddNetworkString("SaveInventory")
util.AddNetworkString("UpdateInventorySlot")
util.AddNetworkString("ClientUpdateSlot")
util.AddNetworkString("Inventory:DropItem")

-- 🔄 Відправити слот
function SendSlot(ply, index, value)
    net.Start("ClientUpdateSlot")
        net.WriteUInt(index, 6)
        net.WriteType(value)
    net.Send(ply)
end

-- 🧠 ID персонажа
function GetCharacterID(ply)
    return ply.nrp_charid
end

-- 🔁 Серіалізація
local function Serialize(tbl)
    return util.TableToJSON(tbl or {}, true)
end

local function Deserialize(str)
    return util.JSONToTable(str or "[]") or {}
end

-- 🛠 Створення таблиці
MySQLite.query([[
    CREATE TABLE IF NOT EXISTS inventories (
        char_id INT PRIMARY KEY,
        inventory TEXT
    )
]])

-- 📤 Зберегти
function SaveInventory(ply)
    local char_id = GetCharacterID(ply)
    if not char_id then return end

    local json = Serialize(ply.Inventory)
    MySQLite.query(string.format([[
        INSERT INTO inventories (char_id, inventory) VALUES (%d, %s)
        ON DUPLICATE KEY UPDATE inventory = VALUES(inventory)
    ]], char_id, MySQLite.SQLStr(json)))
end

-- 📥 Завантажити
function LoadInventory(ply)
    local char_id = GetCharacterID(ply)
    if not char_id then return end

    MySQLite.query(string.format("SELECT inventory FROM inventories WHERE char_id = %d", char_id), function(data)
        if data and data[1] and data[1].inventory then
            ply.Inventory = Deserialize(data[1].inventory)
        else
            ply.Inventory = {}
        end
    end, function(err)
        ply.Inventory = {}
        print("[Inventory:LoadInventory] ERROR:", err)
    end)
end

-- 📦 Оновлення одного слота
net.Receive("UpdateInventorySlot", function(_, ply)
    local index = net.ReadUInt(6)
    local value = net.ReadType()

    ply.Inventory = ply.Inventory or {}
    ply.Inventory[index] = value

    SaveInventory(ply)
end)

-- 💾 Збереження всього інвентаря
net.Receive("SaveInventory", function(_, ply)
    local inv = net.ReadTable()
    if not istable(inv) then return end

    ply.Inventory = inv
    SaveInventory(ply)
end)

-- 🔁 Відкрити інвентар
net.Receive("OpenInventory", function(_, ply)
    net.Start("InventoryData")
        net.WriteTable(ply.Inventory or {})
    net.Send(ply)
end)

-- 🧪 Команда видачі предмета
concommand.Add("giveitem", function(ply, _, args)
    local id = args[1] or "heart"

    ply.Inventory = ply.Inventory or {}

    for i = 1, 35 do
        if not ply.Inventory[i] then
            ply.Inventory[i] = { id = id, count = 1 }
            SendSlot(ply, i, ply.Inventory[i])
            break
        end
    end

    SaveInventory(ply)
end)

-- 📤 Викидання предмета у світ
net.Receive("Inventory:DropItem", function(_, ply)
    local slot = net.ReadUInt(6)
    if not slot then return end

    local inv = ply.Inventory or {}
    local item = inv[slot]
    if not item then return end

    -- Видалення з інвентаря
    inv[slot] = nil
    SendSlot(ply, slot, nil)
    SaveInventory(ply)

    -- Спавн ентиті
    local ent = ents.Create("ent_loot")
    if not IsValid(ent) then return end

    ent:SetPos(ply:GetPos() + ply:GetForward() * 50 + Vector(0, 0, 32))
    ent:SetItemData(item)

    local mdl = "models/Items/item_item_crate.mdl"
    if ItemRegistry[item.id] and ItemRegistry[item.id].worldmodel then
        mdl = ItemRegistry[item.id].worldmodel
    end
    ent:SetModel(mdl)

    ent:Spawn()
end)
