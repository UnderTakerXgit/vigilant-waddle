local ui = {}

local MainFrame = MainFrame or nil

surface.CreateFont('PawsUI.Text.Large', {
    font = 'Open Sans',
    size = 35,
    weight = 500,
    extended = true
})

surface.CreateFont('PawsUI.Text.Normal', {
    font = 'Open Sans',
    size = 21,
    weight = 500,
    extended = true
})

surface.CreateFont('PawsUI.Text.Small', {
    font = 'Open Sans',
    size = 16,
    weight = 500,
    extended = true
})

local factions = {
    TYPE_NONE,
    TYPE_GAR,
    TYPE_JEDI
}

function ui:open(tVehs, eEnt, tPlatforms, tVehicles, tCarList, nFaction)
    if IsValid(MainFrame) then MainFrame:Remove() end

    MainFrame = vgui.Create('PawsUI.Frame')
    MainFrame:SetTitle('Вызов транспорта')
    MainFrame:SetSize(960, 720)
    MainFrame:MakePopup() 
    MainFrame:Center() 
    MainFrame:ShowSettingsButton(LocalPlayer():IsSuperAdmin())

    MainFrame:SetSettingsFunc(function()
        local Menu = DermaMenu()

        Menu:AddOption('Добавить платформу', function()
            netstream.Start('NextRP::AddPlatform', eEnt)
        end):SetIcon('icon16/brick_add.png')

        local platformsMenu = Menu:AddSubMenu('Управление платформами', function() end)
        
        
        for k, v in ipairs(tPlatforms) do
            platformsMenu:AddOption('Удалить платформу №'..k, function()
                netstream.Start('NextRP::RemovePlatform', eEnt, k)
            end):SetIcon('icon16/brick_delete.png')
        end

        local factionMenu = Menu:AddSubMenu('Установить фракцию')
        for k, v in pairs(factions) do
            print(v == nFaction)
            if v == nFaction then
                factionMenu:AddOption(FACTION_LOCALIZATIONS[v]):SetIcon('icon16/accept.png')
            else
                factionMenu:AddOption(FACTION_LOCALIZATIONS[v], function()
                    netstream.Start('NextRP::SetFactionForDealer', eEnt, v)

                    nFaction = v
                end)
            end
        end

        local carlistMenu = Menu:AddSubMenu('Настройка техники')
        for k, v in pairs(tCarList) do
            if tVehicles[v.class] then 
                carlistMenu:AddOption(v.name, function()
                    netstream.Start('NextRP::RemoveVehicle', eEnt, v.class)
                    tVehicles[v.class] = false
                end):SetIcon('icon16/delete.png')
            else
                carlistMenu:AddOption(v.name, function()
                    netstream.Start('NextRP::AddVehicle', eEnt, v.class)
                    tVehicles[v.class] = true
                end):SetIcon('icon16/add.png')
            end
            
            -- carlistMenu:AddOption(v.name):SetIcon('icon16/cancel.png')
        end

        Menu:Open()
    end)

    local sideblock = vgui.Create('PawsUI.Sideblock', MainFrame)

    local content = vgui.Create('PawsUI.Panel', MainFrame)
    content:Dock(FILL)

    local scroll = vgui.Create('PawsUI.ScrollPanel', sideblock)
    scroll:Dock(FILL)
 
    for k, v in ipairs(tVehs) do
        local but = scroll:Add('PawsUI.Button') 
        but:SetTall(68)
        but:SetLabel('')
        but
            :Stick(TOP)
            --:Background(PawsUI.Theme.Background) 
            :Background(PawsUI.Theme.Background)
            :FadeHover(PawsUI.Theme.Blue)
            :CircleClick(PawsUI.Theme.AlphaWhite)
            :On('Paint', function(s, w, h)
                draw.SimpleText(v.name, 'PawsUI.Text.Normal', 64, h * .5 - 7, PawsUI.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(v.desc, 'PawsUI.Text.Small', 64, h * .5 + 7, PawsUI.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)
            :On('DoClick', function(s) 
                content:Clear()

                local skinstoggle = {}
                local elementstoggle = {}

                local skinsselected = false
                local elementselected = {}

                local header = vgui.Create('PawsUI.Panel', content)
                header:SetTall(128)
                header:Dock(TOP)
                header:DockMargin(2, 2, 2, 2)

                header:On('Paint', function(s, w, h)
                    draw.SimpleText(v.name, 'PawsUI.Text.Large', 128, h * .5 - 10, PawsUI.Theme.HoveredText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(v.desc, 'PawsUI.Text.Normal', 128, h * .5 + 10, PawsUI.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end)

                local icon = vgui.Create('PawsUI.EntityIcon', header)
                icon:Dock(LEFT)
                icon:SetSize(128, 128)

                icon:SetIcon(v.class)

                local scrollpanel = vgui.Create('PawsUI.ScrollPanel', content)
                scrollpanel:Dock(FILL)
                scrollpanel:DockMargin(2, 2, 2, 2)
                scrollpanel:InvalidateLayout(true)

                local buttons = TDLib('DIconLayout', scrollpanel)
                    buttons:Stick(FILL)
                buttons:SetSpaceX( 4 )
                buttons:SetSpaceY( 4 )

                buttons:SetSize( scrollpanel:GetWide()-8, scrollpanel:GetTall() - 8 )
	            buttons:SetPos( 4, 4 )

                local skinsTitle = buttons:Add('DLabel')
                skinsTitle:TDLib()
                    :ClearPaint()
                    :Text('Раскраска', 'PawsUI.Text.Normal', nil, TEXT_ALIGN_LEFT)

                skinsTitle:SetWide(content:GetWide())
                skinsTitle:SizeToContentsY()
                for k, skin in pairs(v.skins) do
                    skinstoggle[k] = buttons:Add('PawsUI.Button')

                    skinstoggle[k]:SetLabel(skin)
                    skinstoggle[k]:SetWide( (content:GetWide()-8) * .5 - 8 )
                    skinstoggle[k]:SetTall( 28 ) 
                    skinstoggle[k]:SetBackground(PawsUI.Theme.DarkGray, PawsUI.Theme.Gray)

                    skinstoggle[k]:On('DoClick', function(s)
                        for _, b in pairs(skinstoggle) do 
                            b:SetBackground(PawsUI.Theme.DarkGray, PawsUI.Theme.Gray)
                        end

                        s:Restore()
                        skinsselected = k
                    end)
                end

                local bodyTitle = buttons:Add('DLabel')
                bodyTitle:TDLib()
                    :ClearPaint()
                    :Text('Внешний вид / Экипировка', 'PawsUI.Text.Normal', nil, TEXT_ALIGN_LEFT)

                bodyTitle:SetWide(content:GetWide())
                bodyTitle:SizeToContentsY()
                for vid, variation in pairs(v.variations) do
                    print(variation)
                    elementselected[vid] = false
                    local bodyElementTitle = buttons:Add('DLabel')
                    bodyElementTitle:TDLib()
                        :ClearPaint()
                        :Text(variation.title, 'PawsUI.Text.Normal', nil, TEXT_ALIGN_LEFT)

                    bodyElementTitle:SetWide(content:GetWide())
                    bodyElementTitle:SizeToContentsY()

                    elementstoggle[vid] = {} 

                    for id, lan in pairs(variation.states) do
                        elementstoggle[vid][id] = buttons:Add('PawsUI.Button')

                        elementstoggle[vid][id]:SetLabel(lan)
                        elementstoggle[vid][id]:SetWide( (content:GetWide()-8) * .25 - 8 )
                        elementstoggle[vid][id]:SetTall( 28 ) 
                        elementstoggle[vid][id]:SetBackground(PawsUI.Theme.DarkGray, PawsUI.Theme.Gray)

                        elementstoggle[vid][id]:On('DoClick', function(s)
                            for _, b in pairs(elementstoggle[vid]) do 
                                b:SetBackground(PawsUI.Theme.DarkGray, PawsUI.Theme.Gray)
                            end

                            s:Restore()

                            elementselected[vid] = id
                        end)
                    end                   
                end

                local selectButton = vgui.Create('PawsUI.Button', content)
                selectButton:Dock(BOTTOM)
                selectButton:DockMargin(4,4,7,4) 
                selectButton:SetLabel('Вызвать')
            
                selectButton:On('DoClick', function(s)
                    local can = true
                    if not skinsselected then can = false end

                    for k, _ in pairs(elementselected) do
                        
                        if not elementselected[k] then
                            can = false
                        end

                    end

                    if not can then 
                        s:SetLabel('Для начала выберите все опции!')
                        s:SetBackground(PawsUI.Theme.Red, PawsUI.Theme.LightRed)

                        timer.Simple(2, function()
                            s:Restore()
                            s:SetLabel('Вызвать')
                        end)

                        return 
                    end

                    netstream.Start('NextRP::SpawnCar', eEnt, v.class, skinsselected, elementselected) 
                end)
            end)

        but:DockMargin(6, 0, 6, 6)
        but:InvalidateLayout(true)

        local ico = but:Add('PawsUI.EntityIcon')
        ico:SetIcon(v.class)
        ico:Dock(LEFT, 2)

        local button = but:Add('PawsUI.Button')
        button:SetSize(button:GetWide(), but:GetTall())

        button:ClearPaint()
            :On('DoClick', function()
                but:DoClick()
            end)
    end

    local selectButton = vgui.Create('PawsUI.Button', sideblock)
    selectButton:Dock(BOTTOM)
    selectButton:DockMargin(2,2,2,2)
    selectButton:SetLabel('Вернуть технику')

    function selectButton:DoClick()
        netstream.Start('NextRP::ReturnCar')
    end
    
end

netstream.Hook('NextRP::OpenSpawnerMenu', function(tVehs, eSpawner, tPlatforms, tVehicles, nFaction, tCarList) ui:open(tVehs, eSpawner, tPlatforms, tVehicles, tCarList, nFaction) end)

concommand.Add('nrp_parseveh', function()
    local tr = LocalPlayer():GetEyeTrace()
    local veh = tr.Entity
    if not veh or not veh.LVS then
        print('No veh!')
        return 
    end

    local vehClass = veh:GetClass()

    netstream.Start('NextRP::GetVeh', vehClass, veh)
end)

netstream.Hook('NextRP::GetVeh', function(vehData, vehEnt)

    local skins = {}
    local bodygroups = {}
    local bodygroupsNames = {}

    local veh = vehEnt

    local vehType = 'LFS'
    local vehClass = veh:GetClass()

    local IsRetrived = false
    if vehData ~= nil then IsRetrived = true end

    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Настройка транспорта')
    frame:SetSize(960, 720)
    frame:MakePopup() 
    frame:Center() 
    frame:ShowSettingsButton(false)

    local icon = TDLib( 'DModelPanel', frame )
        :Stick(FILL)
    
    icon:SetLookAt( Vector(0,0,72/2) )
	icon:SetCamPos( Vector(250,0,72))
    icon:SetModel(veh:GetModel())

    local sideblock = vgui.Create('PawsUI.Sideblock', frame)
    sideblock:SetWide(400)

    local scrollpanel = TDLib('PawsUI.ScrollPanel', sideblock)
        :Stick(FILL)

    local buttons = TDLib('DIconLayout', scrollpanel)
    
    buttons:SetSize( scrollpanel:GetWide()-8, scrollpanel:GetTall() - 8 )
	buttons:SetPos( 4, 4 )

    buttons:SetSpaceX( 4 )
    buttons:SetSpaceY( 4 )

    local vehTypePlaceholder = buttons:Add('DLabel')
    vehTypePlaceholder:TDLib()
        :ClearPaint()
        :Text('Тип техники: '..vehType..', класс: '..vehClass, 'font_sans_16', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    local vehDBStatus = buttons:Add('DLabel')
    vehDBStatus:TDLib()
        :ClearPaint()
        :Text(IsRetrived and 'Редактирование техники' or 'Создание техники', 'font_sans_16', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    local vehNamePlaceHolder = buttons:Add('DLabel')
    vehNamePlaceHolder:TDLib()
        :ClearPaint()
        :Text('Название техники: ( Нажмите чтобы изменить )', 'font_sans_16', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    local name = IsRetrived and vehData.name or veh.PrintName

    local vehName = buttons:Add('DButton')
    vehName:TDLib()
        :ClearPaint()
        :Text(name, 'font_sans_21', nil, TEXT_ALIGN_LEFT, nil, nil, true)
        :DivWide(1)
        :On('DoClick', function(s)
            Derma_StringRequest('Название бодигруппа', 'Введите название бодигруппа, это название будет отображено игрокам.\nКак только вы измение это, оно автоматический будет показано игрокам.\nОставте поле пустым чтобы скрыть от игроков.', '', function(sValue)
                s:ClearPaint()
                :Text(sValue, 'font_sans_21', nil, TEXT_ALIGN_LEFT, nil, nil, true)

                name = sValue
            end)
        end)
    vehName:SetText('')

    local vehDescPlaceHolder = buttons:Add('DLabel')
    vehDescPlaceHolder:TDLib()
        :ClearPaint()
        :Text('Краткое описание техники', 'font_sans_16', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    local desc = IsRetrived and vehData.desc or 'Нажмите чтобы изменить'

    local vehDesc = buttons:Add('DButton')
    vehDesc:TDLib()
        :ClearPaint()
        :Text(desc, 'font_sans_21', nil, TEXT_ALIGN_LEFT, nil, nil, true)
        :DivWide(1)
        :On('DoClick', function(s)
            Derma_StringRequest('Название бодигруппа', 'Введите название бодигруппа, это название будет отображено игрокам.\nКак только вы измение это, оно автоматический будет показано игрокам.\nОставте поле пустым чтобы скрыть от игроков.', '', function(sValue)
                s:ClearPaint()
                :Text(sValue, 'font_sans_21', nil, TEXT_ALIGN_LEFT, nil, nil, true)

                desc = sValue
            end)
        end)
    vehDesc:SetText('')

    local skintable = {}
    for i=0, icon.Entity:SkinCount() - 1 do
        table.insert( skintable, i )
    end

    local skinPlaceHolder = buttons:Add('DLabel')
    skinPlaceHolder:TDLib()
        :ClearPaint()
        :Text('Скины', 'font_sans_26', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    for k, i in ipairs(skintable) do
        local btn = buttons:Add( 'PawsUI.Button' )
            :On('DoClick', function()
                icon.Entity:SetSkin(i)
            end)
            :On('DoRightClick', function(s)
                Derma_StringRequest('Название скина', 'Введите название скина, это название будет отображено игрокам.\nКак только вы измение это, оно автоматический будет показано игрокам.\nОставте поле пустым чтобы скрыть от игроков.', '', function(sValue)
                    if sValue == '' then
                        s:SetLabel('Не отображается')
                        skins[i] = nil
                    else
                        s:SetLabel(sValue)
                        skins[i] = sValue
                    end
                end)
            end)

        local skinname = IsRetrived and vehData.skins[i] or 'Не отображается'
        skins[i] = IsRetrived and vehData.skins[i] or nil

        btn:SetWide( buttons:GetWide() * .5 - 16 )
        btn:SetLabel(skinname)
        btn:SetTall( 28 )
    end

    local spacer = buttons:Add('DPanel')
    spacer:SetSize(buttons:GetWide(), 2)
    function spacer:Paint(s, w, h)
        
    end

    local bodygroups1 = {}
    for k, v in pairs(icon.Entity:GetBodyGroups()) do
        if v.num <= 1 then continue end
        bodygroups1[#bodygroups1 + 1] = v
    end

    local bgPlaceHolder = buttons:Add('DLabel')
    bgPlaceHolder:TDLib()
        :ClearPaint()
        :Text('Бодигруппы', 'font_sans_26', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    for k, v in pairs(bodygroups1) do
        local bname = v.name

        if IsRetrived and vehData.variations[v.id] and vehData.variations[v.id].title then
            bname = vehData.variations[v.id].title
        end

        local title = buttons:Add('DButton')
        title:TDLib()
            :ClearPaint()
            :Text(bname .. ' ( Нажмите что бы изменить )', 'font_sans_21', nil, TEXT_ALIGN_LEFT, nil, nil, true)
            :DivWide(1)
            :On('DoClick', function(s)
                Derma_StringRequest('Название бодигруппа', 'Введите название бодигруппа, это название будет отображено игрокам.\nКак только вы измение это, оно автоматический будет показано игрокам.\nОставте поле пустым чтобы скрыть от игроков.', '', function(sValue)
                    s:ClearPaint()
                    :Text(sValue, 'font_sans_21', nil, TEXT_ALIGN_LEFT, nil, nil, true)
                    
                    bodygroupsNames[v.id] = sValue
                end)
            end)

        bodygroups[v.id] = {}
        bodygroupsNames[v.id] = bname
        title:SetText('')
        for id, _ in pairs(v.submodels) do
            local sbname = nil

            if IsRetrived and vehData.variations[v.id] and vehData.variations[v.id].states[id] and vehData.variations[v.id].states[id] then
                sbname = vehData.variations[v.id].states[id]
            end
            local btn = buttons:Add( 'PawsUI.Button' )
            btn:TDLib()
                :On('DoClick', function()
                    icon.Entity:SetBodygroup(v.id, id)
                end)
                :On('DoRightClick', function(s)
                    Derma_StringRequest('Название бодигруппа', 'Введите название бодигруппа, это название будет отображено игрокам.\nКак только вы измение это, оно автоматический будет показано игрокам.\nОставте поле пустым что-бы скрыть от игроков.', '', function(sValue)
                        if sValue == '' then
                            s:SetLabel('Не отображается')
                            bodygroups[v.id][id] = nil
                        else
                            s:SetLabel(sValue)
                            bodygroups[v.id][id] = sValue
                        end
                    end)
                end)

            bodygroups[v.id][id] = sbname
        
            btn:SetWide( buttons:GetWide() * .5 - 16 )
            btn:SetTall( 28 )
            btn:SetLabel(sbname or 'Не отображается')
        end
    end

    local CategList

    local vehPermsPlaceHolder = buttons:Add('DLabel')
    vehPermsPlaceHolder:TDLib()
        :ClearPaint()
        :Text('Настройка прав', 'font_sans_16', nil, TEXT_ALIGN_LEFT)
        :DivWide(1)

    local permsTable = IsRetrived and vehData.permisions or {}
    PrintTable(permsTable)
    local function addJob(v) 
        if not permsTable[v.id] then
            permsTable[v.id] = {
                name = v.name,
                permisions = {}
            }
        end

        local jobBase = CategList:Add('DCollapsibleCategory')
        jobBase:SetWide( buttons:GetWide() - 16 )
        jobBase:SetLabel( v.name )

        local contents = vgui.Create('DPanelList', jobBase)

        contents:SetPadding(0)
        contents:SetSpacing(4)
        jobBase:SetContents(contents)	

        local ranks = vgui.Create( "DLabel" )
                ranks:Dock(TOP)
                ranks:SetText('ЗВАНИЯ:')
                ranks:SizeToContents()
            contents:Add(ranks)

        for k, r in SortedPairsByMemberValue(v.ranks, 'sortOrder') do
            local rankCheck = vgui.Create( "DCheckBoxLabel" )
                rankCheck:Dock(TOP)
                rankCheck:SetText(k)
                rankCheck:SetValue( permsTable[v.id].permisions[k] or false )
                rankCheck:SizeToContents()
                function rankCheck:OnChange(bVal)
                    permsTable[v.id].permisions[k] = bVal
                end
            contents:Add(rankCheck)
        end

        local flags = vgui.Create( "DLabel" )
                flags:Dock(TOP)
                flags:SetText('ПРИПИСКИ:')
                flags:SizeToContents()
            contents:Add(flags)

        for k, f in pairs(v.flags) do
            local rankCheck = vgui.Create( "DCheckBoxLabel" )
                rankCheck:Dock(TOP)
                rankCheck:SetText(f.id)
                rankCheck:SetValue( permsTable[v.id].permisions[k] or false )
                rankCheck:SizeToContents()
                function rankCheck:OnChange(bVal)
                    permsTable[v.id].permisions[k] = bVal
                end
            contents:Add(rankCheck)
        end

        CategList:InvalidateLayout(true)
        permsTable[v.id].panel = jobBase
    end

    local vehPermsAdd = buttons:Add( 'PawsUI.Button' )
    vehPermsAdd:TDLib()
        :On('DoClick', function()
            local Menu = vgui.Create('Paws.Menu')

            for k, v in pairs(NextRP.Jobs) do
                if permsTable[v.id] then continue end
                Menu:AddOption(v.name, function()
                    addJob(v)
                end)
            end
            
            Menu:Open()
        end)

    vehPermsAdd:SetWide( buttons:GetWide() * .5 - 16 )
    vehPermsAdd:SetTall( 28 )
    vehPermsAdd:SetLabel('Добавить профессию')

    local vehPermsRemove = buttons:Add( 'PawsUI.Button' )
    vehPermsRemove:TDLib()
        :On('DoClick', function()
            local Menu = vgui.Create('Paws.Menu')
            for k, v in pairs(permsTable) do
                Menu:AddOption(v.name, function()
                    v.panel:Remove()
                    permsTable[k] = nil
                end)
            end
            Menu:Open()
        end)

    vehPermsRemove:SetWide( buttons:GetWide() * .5 - 16 )
    vehPermsRemove:SetTall( 28 )
    vehPermsRemove:SetLabel('Удалить профессию')

    CategList = buttons:Add('DCategoryList')
    CategList:SetWide( buttons:GetWide() - 16 )
    CategList:SetTall(500)
    function CategList:Paint() end

    if IsRetrived then
        for k, v in pairs(permsTable) do
            local job = NextRP.GetJobByID(k)
            addJob(job)
        end
    end

    local saveButton = vgui.Create('PawsUI.Button', sideblock)
    saveButton:SetLabel('Сохранить')
    saveButton:Dock(BOTTOM)
    saveButton:DockMargin(5, 5, 5, 5)

    saveButton:On('DoClick', function()
        local vehTable = {}
        vehTable.class = vehClass
        vehTable.name = name
        vehTable.desc = desc
        vehTable.variations = {}
        vehTable.skins = skins

        for k, v in pairs(permsTable) do
            v.panel = nil
        end

        vehTable.permisions = permsTable

        for k, v in pairs(bodygroups) do
            local add = false
            for k, e in pairs(v) do
                if e then add = true end
            end

            if add then vehTable.variations[k] = {
                title = bodygroupsNames[k],
                states = v
            } end
        end

        netstream.Start('NextRP::VehUpdate', vehTable)

        frame:Remove()
    end)

end)

concommand.Add('nrp_saveall', function()
    if not LocalPlayer():IsSuperAdmin() then return end
    
    netstream.Start('NextRP::SaveDealers')
end)