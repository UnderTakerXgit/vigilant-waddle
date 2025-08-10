local MODULE = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

local PANEL = {}

function PANEL:Init()
    self:TDLib()
        :ClearPaint()
        :Background(Colors.Button)
end

function PANEL:AddOption( strText, funcFunction )

	local pnl = vgui.Create( 'Paws.MenuOption', self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return pnl

end

function PANEL:AddSubMenu( strText, funcFunction )

	local pnl = vgui.Create( 'Paws.MenuOption', self )
	local SubMenu = pnl:AddSubMenu( strText, funcFunction )

	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return SubMenu, pnl

end

vgui.Register('Paws.Menu', PANEL, 'DMenu')