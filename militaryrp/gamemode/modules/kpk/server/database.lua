-- Database setup and periodic cleanup for KPK
NextRP = NextRP or {}
NextRP.KPK = NextRP.KPK or {}
local KPK  = NextRP.KPK
local function CFG() return (NextRP.KPK and NextRP.KPK.Config) or {} end
local function now() return os.time() end

-- Create tables if they do not exist
local function createTables()
    local mysql = MySQLite.isMySQL and MySQLite.isMySQL() or false
    local idCol = mysql and 'INT AUTO_INCREMENT PRIMARY KEY' or 'INTEGER PRIMARY KEY AUTOINCREMENT'

    MySQLite.query([[CREATE TABLE IF NOT EXISTS kpk_messages(
            id ]]..idCol..[[,
            category VARCHAR(16),
            channel  VARCHAR(64),
            steam_id VARCHAR(25),
            char_id  INT,
            content  TEXT,
            created_at INT,
            reply_to INT,
            edited_at INT,
            is_announce INT DEFAULT 0
        );]])

    MySQLite.query([[CREATE TABLE IF NOT EXISTS kpk_pins(
            category VARCHAR(16),
            channel  VARCHAR(64),
            message_id INT,
            pinned_by  VARCHAR(25),
            pinned_at  INT,
            PRIMARY KEY (category, channel)
        );]])

    MySQLite.query([[CREATE TABLE IF NOT EXISTS kpk_profiles(
            steam_id VARCHAR(25) PRIMARY KEY,
            playtime INT DEFAULT 0
        );]])

    -- Подтверждения служебных объявлений
    MySQLite.query([[CREATE TABLE IF NOT EXISTS kpk_acks(
            message_id INT,
            steam_id   VARCHAR(25),
            confirmed_at INT,
            PRIMARY KEY (message_id, steam_id)
        );]])

    -- Задачи
    MySQLite.query([[CREATE TABLE IF NOT EXISTS kpk_tasks(
            id ]]..idCol..[[,
            category     VARCHAR(16),
            title        TEXT,
            description  TEXT,
            creator_sid  VARCHAR(25),
            assignee_sid VARCHAR(25),
            status       VARCHAR(16),
            deadline     INT,
            created_at   INT,
            closed_at    INT
        );]])

    -- Индексы для ускорения запросов
    MySQLite.query([[CREATE INDEX IF NOT EXISTS idx_kpk_messages_cat_ch_id ON kpk_messages(category, channel, id);]])
    MySQLite.query([[CREATE INDEX IF NOT EXISTS idx_kpk_messages_created_at ON kpk_messages(created_at);]])
    MySQLite.query([[CREATE INDEX IF NOT EXISTS idx_kpk_messages_reply_to ON kpk_messages(reply_to);]])
    MySQLite.query([[CREATE INDEX IF NOT EXISTS idx_kpk_tasks_cat ON kpk_tasks(category);]])
    MySQLite.query([[CREATE INDEX IF NOT EXISTS idx_kpk_tasks_status ON kpk_tasks(status);]])
end

-- Ensure new columns when upgrading
local function ensureColumns()
    local isMy = MySQLite.isMySQL and MySQLite.isMySQL() or false
    local function addcol(tbl, col, def)
        if isMy then
            MySQLite.query("SHOW COLUMNS FROM "..tbl.." LIKE '"..col.."';", function(rows)
                if not rows or #rows == 0 then
                    MySQLite.query("ALTER TABLE "..tbl.." ADD COLUMN "..col.." "..def..";")
                end
            end)
        else
            MySQLite.query("PRAGMA table_info("..tbl..");", function(rows)
                local ok = false
                for _, r in ipairs(rows or {}) do
                    local n = r.name or r.Name
                    if string.lower(tostring(n or '')) == string.lower(col) then ok = true break end
                end
                if not ok then
                    MySQLite.query("ALTER TABLE "..tbl.." ADD COLUMN "..col.." "..def..";")
                end
            end)
        end
    end
    addcol('kpk_messages', 'reply_to', 'INT')
    addcol('kpk_messages', 'edited_at', 'INT')
    addcol('kpk_messages', 'is_announce', 'INT DEFAULT 0')
end

hook.Add('DatabaseInitialized', 'KPK::InitDB', function()
    createTables()
    ensureColumns()
    print('[KPK] Таблицы/миграции КПК готовы.')

    -- Retention: clean old messages every 24h
    if timer.Exists('KPK::Retention') then timer.Remove('KPK::Retention') end
    timer.Create('KPK::Retention', 24*3600, 0, function()
        local days = (CFG().retention_days or 30)
        local threshold = now() - (days * 24 * 3600)
        MySQLite.query('DELETE FROM kpk_messages WHERE created_at < '..threshold..';')
        -- задачи не чистим автоматически
    end)
end)
