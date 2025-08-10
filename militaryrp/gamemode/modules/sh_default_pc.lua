local PLAYER = {}

-- Value of -1 = set to config value, if a corresponding setting exists
PLAYER.DisplayName			= 'NextRP Player Class'

PLAYER.WalkSpeed			= 70		-- How fast to move when not running
PLAYER.RunSpeed				= 75		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= .5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 160		-- How powerful our jump should be
PLAYER.CanUseFlashlight		= true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= false		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= false		-- Automatically swerves around other players
PLAYER.UseVMHands			= true		-- Uses viewmodel hands

function PLAYER:GetHandsModel()
	-- return { model = 'models/weapons/c_arms_cstrike.mdl', skin = 1, body = '0100000' }

	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )
end

player_manager.RegisterClass('player_nextrp', PLAYER, 'player_default')