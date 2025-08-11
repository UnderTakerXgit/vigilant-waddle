-- Entry point for server-side KPK module
-- Splits database, profile and network logic into dedicated files for readability.

-- Database setup and migrations
include('server/database.lua')
-- Player profile tracking
include('server/profile.lua')
-- Main networking logic and utility functions
include('server/main.lua')
