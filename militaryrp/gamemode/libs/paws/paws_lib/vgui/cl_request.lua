local MODULE = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

function MODULE:DoStringRequest(sTitle, sText, sDefaultText, fEnter, fCancel, sEnterButtonText, sCancelButtonText)

    local Blur = TDLib( 'DPanel' )
        :ClearPaint()
        :Stick(FILL)
        :Blur()
        :FadeIn(2)

    Blur:SetDrawOnTop( true )

    local Window = vgui.Create( 'DFrame' )
	
    Window:TDLib()
        :ClearPaint()
        :Background(Colors.Base, 5)
        :FadeIn()
    
    Window:SetTitle( sTitle or 'Ввод данных' )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetDrawOnTop( true )
    
	local InnerPanel = vgui.Create( 'DPanel', Window )
	InnerPanel:SetPaintBackground( false )

	local Text = vgui.Create( 'DLabel', InnerPanel )
	Text:SetText( sText or 'Введите данные в поле ниже' )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( Colors.Text )

	local TextEntry = vgui.Create( 'DTextEntry', InnerPanel )
	TextEntry:SetText( sDefaultText or '' )
	TextEntry.OnEnter = function() Window:Close() Blur:Remove() fEnter( TextEntry:GetValue() ) end

	local ButtonPanel = vgui.Create( 'DPanel', Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetPaintBackground( false )

	local Button = vgui.Create( 'DButton', ButtonPanel )
	Button:SetPos( 5, 5 )
	Button.DoClick = function() Window:Close() Blur:Remove() fEnter( TextEntry:GetValue() ) end

    Button:TDLib()
        :ClearPaint()
        :Background(Colors.Button)
        :FadeHover(Colors.ButtonHover)
        :CircleClick()
        :Text(sEnterButtonText or 'OK', 'DermaDefault', Colors.Text)

    Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )

	local ButtonCancel = vgui.Create( 'DButton', ButtonPanel )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() Blur:Remove() if ( fCancel ) then fCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

    ButtonCancel:TDLib()
        :ClearPaint()
        :Background(Colors.Button)
        :FadeHover(Colors.CloseHover)
        :CircleClick()
        :Text(sCancelButtonText or 'Отмена', 'DermaDefault', Colors.Text)

    ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = Text:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w + 50, h + 25 + 75 + 10 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:StretchToParent( 5, 5, 5, 35 )

	TextEntry:StretchToParent( 5, nil, 5, nil )
	TextEntry:AlignBottom( 5 )

	TextEntry:RequestFocus()
	TextEntry:SelectAllText( true )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

end

function MODULE:DoButtonRequest(sTitle, sText, sDefaultButton, fEnter, fCancel, sEnterButtonText, sCancelButtonText)

    local Blur = TDLib( 'DPanel' )
        :ClearPaint()
        :Blur()
        :FadeIn(2)

	Blur:SetSize(ScrW(), ScrH())
    Blur:SetDrawOnTop( true )

    local Window = vgui.Create( 'DFrame' )
	
    Window:TDLib()
        :ClearPaint()
        :Background(Colors.Base, 5)
        :FadeIn()
    
    Window:SetTitle( sTitle or 'Ввод данных' )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetDrawOnTop( true )
    
	local InnerPanel = vgui.Create( 'DPanel', Window )
	InnerPanel:SetPaintBackground( false )

	local Text = vgui.Create( 'DLabel', InnerPanel )
	Text:SetText( sText or 'Введите данные в поле ниже' )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( Colors.Text )

	local TextEntry = vgui.Create( 'DBinder', InnerPanel )
	TextEntry:SetSelectedNumber( sDefaultButton or '' )
	// TextEntry.OnEnter = function() Window:Close() Blur:Remove() fEnter( TextEntry:GetValue() ) end

	local ButtonPanel = vgui.Create( 'DPanel', Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetPaintBackground( false )

	local Button = vgui.Create( 'DButton', ButtonPanel )
	Button:SetPos( 5, 5 )
	Button.DoClick = function() Window:Close() Blur:Remove() fEnter( TextEntry:GetValue() ) end

    Button:TDLib()
        :ClearPaint()
        :Background(Colors.Button)
        :FadeHover(Colors.ButtonHover)
        :CircleClick()
        :Text(sEnterButtonText or 'OK', 'DermaDefault', Colors.Text)

    Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )

	local ButtonCancel = vgui.Create( 'DButton', ButtonPanel )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() Blur:Remove() if ( fCancel ) then fCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

    ButtonCancel:TDLib()
        :ClearPaint()
        :Background(Colors.Button)
        :FadeHover(Colors.CloseHover)
        :CircleClick()
        :Text(sCancelButtonText or 'Отмена', 'DermaDefault', Colors.Text)

    ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = Text:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w + 50, h + 25 + 75 + 10 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:StretchToParent( 5, 5, 5, 35 )

	//TextEntry:StretchToParent( 5, nil, 5, nil )
	
	TextEntry:Center(  )
	TextEntry:AlignBottom( -2 )

	// TextEntry:RequestFocus()
	// TextEntry:SelectAllText( true )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

end