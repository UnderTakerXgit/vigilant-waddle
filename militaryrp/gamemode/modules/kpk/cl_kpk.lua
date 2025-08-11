-- Entry point for client-side KPK module
-- This file includes separated client logic parts to keep things organized.

-- Core UI and state helpers
include('client/core.lua')
-- Draft management utilities
include('client/drafts.lua')
-- Mention detection helpers
include('client/mentions.lua')
-- Link preview builders
include('client/links.lua')
-- Main UI implementation and network hooks
include('client/main.lua')
