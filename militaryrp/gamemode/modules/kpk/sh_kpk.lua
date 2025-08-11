-- When running on the server make sure all clientside pieces are
-- sent to players so they can be included from cl_kpk.lua without
-- "file not found" errors.
if SERVER then
    AddCSLuaFile('client/core.lua')    -- basic UI helpers
    AddCSLuaFile('client/drafts.lua')  -- draft saving utilities
    AddCSLuaFile('client/mentions.lua')-- @mention detection
    AddCSLuaFile('client/links.lua')   -- link preview support
    AddCSLuaFile('client/main.lua')    -- main UI and hooks
    AddCSLuaFile('shared/permissions.lua') -- share permission checks
end

-- Shared permissions are used by both client and server logic
include('shared/permissions.lua')
