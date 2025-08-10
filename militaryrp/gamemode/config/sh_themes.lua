NextRP.Style = {}  -- Создаем таблицу NextRP.Style, если она еще не существует

NextRP.Style.ID = 'productionlib' -- Можоно сносить, похуй,
                            -- измненение этого приведёт к сбросу всего кеша!
                            -- ОСТОРОЖНО С ЭТОЙ ШТУКОЙ, МЕНЯТЬ ТОЛЬКО ЕСЛИ ЗНАЕТЕ ЧТО ДЕЛАТЬ!
NextRP.Style.Theme = {
    Background = Color( 40, 40, 40, 200 ),  -- Для заднего фона.
                                            -- Совет: Используйте оттенки белого или черного, никакой радуги.

    Primary = Color( 50, 50, 50, 200 ),     -- Основной цвент окон и элементов.
                                            -- Совет: Используйте оттенки белого или черного, никакой радуги.

    Accent = Color( 255, 255, 0 ),          -- Цвет для элементов декора. (полосы, разделители и т.д.)

    Text = Color( 220, 221, 225 ),          -- Цвет текста
    HoveredText = Color( 245, 246, 250 ),   -- Цвет текста, но при наведении. (кнопки и другие активные эелементы)
    HightlightText = Color( 255, 255, 0 ),  -- Цвет текста, но для выделения.
                                            -- Совет: Немного темнее или светле цвета декора.
                                            -- (название в табе, выделенный текст в авто сообщениях и т.д.)

    DarkScroll = Color( 255, 255, 0 ),      -- Светло желтый цвет
    Scroll = Color( 255, 255, 0 ),          -- Цвет скролла

    DarkGray = Color( 47, 54, 64 ),         -- Тёмно-серый
    Gray = Color( 113, 128, 147 ),          -- Серый
    Red = Color( 194, 54, 22 ),             -- Красный цвет.
                                            -- Совет: Используйте оттенки.
    LightRed = Color( 232, 65, 24 ),        -- Красный, но светлее. 
                                            -- Совет: Используйте оттенки.
    DarkBlue = Color( 64, 115, 158 ),       -- Тёмно-синий
    Blue = Color( 0, 151, 230 ),            -- Синий
    DarkGreen = Color( 68, 189, 50 ),       -- Зелёный, но темнее.
                                            -- Совет: Используйте оттенки, старайтесь делать его менее кислотным.
    Green = Color( 76, 209, 55 ),           -- Зелёный. 
                                            -- Совет: Используйте оттенки, старайтесь делать его менее кислотным.
    Yellow = Color( 251, 197, 49 ),         -- Желтый

    AlphaWhite = Color( 220, 221, 225, 50 ) -- Этот цвет нужен для блюра, лучше не трогать.
}

NextRP.Style.Materials = {
    CloseButton = 'https://i.imgur.com/uSqgmuD.png',                -- Кнопка закрытия
    SettingsButton = 'https://i.imgur.com/5em8djK.png',             -- Настройки
    Stun = 'https://i.imgur.com/58JdOKP.png',                       -- Оглушение
    TalkIcon = 'https://i.imgur.com/rtHtwMn.png',                   -- *Говорит*

    CharacterSystemBackground = 'https://i.imgur.com/AcUtLQQ.png',  -- Фон системы персонажей https://i.imgur.com/M0fvX43.png

    LogoWatermark = 'https://i.imgur.com/xdPIrGC.png',              -- Лого "Ватермарка", без лишних элементов
    LogoNormal = 'https://i.imgur.com/xdPIrGC.png',                 -- Нормальное лого https://imgur.com/a/saVRyRN.png

    CloneIcon = 'https://i.imgur.com/JZ4VhnU.png',                  -- Иконка для клонов
    DroidIcon = 'https://i.imgur.com/IgF8O7L.png',                  -- Иконка для клонов
    JediIcon = 'https://i.imgur.com/9ciyG6W.png',                   -- Иконка для джедаев
    RPRoleIcon = 'https://i.imgur.com/9I2Lx9q.png',                 -- Иконка для РП ролей
    ServerStuffIcon = 'https://i.imgur.com/UcxwrAw.png',            -- Иконка для персонала сервера

    Health = 'https://i.imgur.com/5j8kg8i.png',                     -- Иконка сердца для худа
    Armor = 'https://i.imgur.com/Chel6P0.png',                      -- Иконка щита для худа

    SkullIcon = 'https://i.imgur.com/K73SvR5.png',                  -- Иконка черепа для экрана смерти

    RadioOn = 'https://i.imgur.com/ScniBHA.png',                    -- Рация "включена"
    RadioOff = 'https://i.imgur.com/mDNbvGA.png'                    -- Рация "выключена"
}

hook.Run('NextRP::ThemeLoaded') -- Эт не удаляй 
