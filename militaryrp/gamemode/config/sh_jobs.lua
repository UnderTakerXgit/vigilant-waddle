TEAM_SURVIVOR = NextRP.createJob('Рекрут', {
    id = 'survivor',
    model = {'models/re6_bsaa_arma3head_gear1_pm.mdl'}, -- Звичайний громадянин
    color = Color(90, 90, 90), -- Сірий
    default_rank = 'Рекрут',
    ranks = {
        ['Рекрут'] = {
            sortOrder = 1,
            model = {
                'models/re6_bsaa_arma3head_gear1_pm.mdl'
            },
            hp = 100,
            ar = 0,
            weapon = {
                default = {'aspiration_hands'}, -- Лом
                ammunition = {''}
            },
            fullRank = 'Рекрут',
            whitelist = false
        },
    },

    flags = {},
    type = TYPE_GAR, -- Тип фракції: "Виживші"
    control = CONTROL_NONE, -- Не належить до жодної з головних сил
    start = true, -- Стартова профа для новачків
    category = 'Рекруты'
})

------------------------------------------------------------------

TEAM_RESEARCH = NextRP.createJob('Научное Подразделение', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'rsrch', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {
        'models/dizcordum/citizens/playermodels/pm_male_07s1.mdl'
    },
    color = Color(64, 224, 208),
    -- Звания
    default_rank = 'R-1',
    ranks = {
        ['R-1'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Стажёр',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['R-2'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 2,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Специалист',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['R-3'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 3,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Старший специалист',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['R-4'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Куратор отдела',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
        ['R-5'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Главный исследователь',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
    },
    flags = {
        ['vir'] = {
            id = 'Вирусолог',

            model = {
            },
            weapon = {
                ammunition = {''},
                default = {''}
            },

            hp = 0,
            ar = 0,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['medevac'] = {
            id = 'Медик',

            model = {
            },
            weapon = {
                ammunition = {'weapon_defibrillator','weapon_eft_afak'},
                default = {''}
            },

            hp = 0,
            ar = 0,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
    },


    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_GAR, TYPE_JEDI, TYPE_UNDEF, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_GAR, CONTROL_CIS, CONTROL_HEADHUNTERS, CONTROL_NONE, пояснения в modules/sh_jobs.lua
    -- Стартовая профа?
    start = false,
    -- Категория профы
    category = 'Научный Персонал'
})

------------------------------------------------------------------

TEAM_CMD = NextRP.createJob('Командование', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'cmd', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {
        'models/dizcordum/citizens/playermodels/pm_male_07s1.mdl'
    },
    color = Color(64, 224, 208),
    -- Звания
    default_rank = 'C-1',
    ranks = {
        ['C-1'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_doorcontrol','weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Тактический Координатор',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
        ['C-2'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 2,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_doorcontrol','weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Офицер подразделения',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
        ['C-3'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 3,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_doorcontrol','weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Офицер сектора',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
        ['C-4'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands','weapon_doorcontrol'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Директор объекта',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
            ['C-5'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                'models/player/scifi_louis.mdl',
                'models/player/scifi_mp1.mdl',
                'models/player/scifi_mp2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands','weapon_doorcontrol'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Проконсул Umbrella',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_OTHER, -- ТИП, могут быть TYPE_GAR, TYPE_JEDI, TYPE_UNDEF, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_GAR, CONTROL_CIS, CONTROL_HEADHUNTERS, CONTROL_NONE, пояснения в modules/sh_jobs.lua
    -- Стартовая профа?
    start = false,
    -- Категория профы
    category = 'Командование'
})

------------------------------------------------------------------

TEAM_USS = NextRP.createJob('U.S.S.', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'uss', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {
        'models/player/w4ys3rs_garage/gru/gru_2_face.mdl'
    },
    color = Color(64, 224, 208),
    -- Звания
    default_rank = 'U-1',
    ranks = {
        ['U-1'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/w4ys3rs_garage/gru/gru_1_balaclava.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Агент',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['U-2'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 2,
            -- Основные настройки
            model = { -- Модели
                'models/player/w4ys3rs_garage/gru/gru_1_balaclava.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Старший агент',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['U-3'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 3,
            -- Основные настройки
            model = { -- Модели
                'models/player/w4ys3rs_garage/gru/gru_2_face.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {''} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Инспектор',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['U-4'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                'models/player/w4ys3rs_garage/gru/gru_2_face.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Капитан безопасности',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
        ['U-5'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                'models/player/w4ys3rs_garage/gru/gru_2_face.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Начальник внутренней безопасности',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
    },
    flags = {
        ['agent'] = {
            id = 'Агент',

            model = {
            },
            weapon = {
                ammunition = {'arc9_eft_mcx', 'arc9_eft_f1'},
                default = {'arc9_eft_m1911'}
            },

            hp = 130,
            ar = 50,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['podav'] = {
            id = 'Агент подавления',

            model = {
            },
            weapon = {
                ammunition = {'arc9_eft_m590', 'arc9_eft_m7290'},
                default = {'arc9_eft_m9a3','stungun','weapon_cuff_elastic'}
            },

            hp = 125,
            ar = 40,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['insp'] = {
            id = 'Инспектор',

            model = {''},
            weapon = {
                ammunition = {'arc9_eft_m7290', 'arc9_eft_mp5'},
                default = {'arc9_eft_rsh12', 'arc9_eft_melee_taran', 'stungun', 'weapon_cuff_elastic'}
            },

            hp = 130,
            ar = 30,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['inst'] = {
            id = 'Инструктор',

            model = {''},
            weapon = {
                ammunition = {''},
                default = {'arc9_eft_pb', 'arc9_eft_melee_taran', 'stungun', 'weapon_cuff_elastic'}
            },

            hp = 120,
            ar = 50,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
    },


    -- ТИПы и КОНТРОЛы
    type = TYPE_OTHER, -- ТИП, могут быть TYPE_GAR, TYPE_JEDI, TYPE_UNDEF, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_GAR, CONTROL_CIS, CONTROL_HEADHUNTERS, CONTROL_NONE, пояснения в modules/sh_jobs.lua
    -- Стартовая профа?
    start = false,
    -- Категория профы
    category = 'U.S.S.'
})

------------------------------------------------------------------

TEAM_POLICE = NextRP.createJob('U.B.C.S.', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'ubcs', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {
        'models/cool_umbe_2.mdl'
    },
    color = Color(64, 224, 208),
    -- Звания
    default_rank = 'P-1',
    ranks = {
        ['P-1'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/cool_umbe_2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun','stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Оперативник',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['P-2'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 2,
            -- Основные настройки
            model = { -- Модели
                'models/cool_umbe_2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun','stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Капрал',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['P-3'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 3,
            -- Основные настройки
            model = { -- Модели
                'models/cool_umbe_2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun','stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Специалист',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['P-4'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                'models/cool_umbe_2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun','stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Лейтенант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
        ['P-5'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                'models/cool_umbe_2.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'aspiration_hands'}, -- При спавне
                ammunition = {'weapon_cuff_elastic','weapon_stungun','stungun'} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'Командир',
            -- Вайтлист
            whitelist = true -- Может ли выдавать профы и изменять персонажей
        },
    },
    flags = {
        ['ops'] = {
            id = 'Оперативник',

            model = {
            },
            weapon = {
                ammunition = {'arc9_eft_ak74m', 'arc9_eft_m1911', 'arc9_eft_f1'},
                default = {''}
            },

            hp = 130,
            ar = 50,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['shturm'] = {
            id = 'Тяжелый оперативник',

            model = {
            },
            weapon = {
                ammunition = {'arc9_eft_m60e4'},
                default = {'arc9_eft_rgd5', 'arc9_eft_m9a3'}
            },

            hp = 250,
            ar = 200,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['recon'] = {
            id = 'Разведчик',

            model = {''},
            weapon = {
                ammunition = {'arc9_eft_m7290','arc9_eft_m18','arc9_eft_sp81','realistic_hook'},
                default = {'arc9_eft_stm9', 'arc9_eft_glock17', 'arc9_eft_rangefinder'}
            },

            hp = 100,
            ar = 25,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['sniper'] = {
            id = 'Снайпер',

            model = {''},
            weapon = {
                ammunition = {'arc9_eft_t5000'},
                default = {''}
            },

            hp = 100,
            ar = 25,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['eng'] = {
            id = 'Инженер',

            model = {''},
            weapon = {
                ammunition = {'weapon_doorcontrol','weapon_lvsrepair','alydus_fortificationbuildertablet'},
                default = {''}
            },

            hp = 100,
            ar = 50,

            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
    },


    -- ТИПы и КОНТРОЛы
    type = TYPE_OTHER, -- ТИП, могут быть TYPE_GAR, TYPE_JEDI, TYPE_UNDEF, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_GAR, CONTROL_CIS, CONTROL_HEADHUNTERS, CONTROL_NONE, пояснения в modules/sh_jobs.lua
    -- Стартовая профа?
    start = false,
    -- Категория профы
    category = 'U.B.C.S.'
})

------------------------------------------------------------------

-- RPROLE
TEAM_RPROLE = NextRP.createJob('РП Роль', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'rprole', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/player/combine_super_soldier.mdl'},
    color = Color(255, 255, 255),
    -- Звания
    default_rank = 'rprole',
    ranks = {
        ['rprole'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/combine_super_soldier.mdl'
            },
            hp = 200, -- ХП
            ar = 200, -- Армор
            weapon = { -- Оружие
                default = {'hologram_swep'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            
            fullRank = 'РП Роль',
            -- Вайтлист
            whitelist = false -- Может ли выдавать профы и изменять персонажей
        },
    },
    flags = {
    },
	    -- ТИПы и КОНТРОЛы
    type = TYPE_RPROLE, -- ТИП, могут быть TYPE_GAR, TYPE_JEDI, TYPE_UNDEF, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_GAR, CONTROL_CIS, CONTROL_HEADHUNTERS, CONTROL_NONE, пояснения в modules/sh_jobs.lua
    -- Стартовая профа?
    start = false,
    -- Категория профы
    category = 'RP'
})

-- ADMIN
TEAM_ADMIN = NextRP.createJob('Администратор', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'admin', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/taggart/gallahan.mdl'},
    color = Color(220, 221, 225),
    -- Звания
    default_rank = 'ADMIN',
    ranks = {
        ['ADMIN'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 21,
            -- Основные настройки
            model = { -- Модели
                'models/taggart/gallahan.mdl'
            },
            hp = 20000, -- ХП
            ar = 20000, -- Армор
            weapon = { -- Оружие
                default = {'weapon_physgun', 'gmod_tool', 'weapon_doorcontrol', 'weapon_defibrillator'}, -- При спавне
                ammunition = {} -- В оружейке
            },

            -- Форматирование
            natoCode = '',
            fullRank = 'Администратор',

            -- Вайтлист
            whitelist = true -- Может ли выдавать эту профу и менять звания
        },
		['DEV'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 20,
            -- Основные настройки
            model = { -- Модели
                'models/cyanblue/debuotaku/debuotaku.mdl'
            },
            hp = 200000, -- ХП
            ar = 200000, -- Армор
            weapon = { -- Оружие
                default = {'weapon_physgun', 'gmod_tool', 'weapon_doorcontrol', 'weapon_defibrillator'}, -- При спавне
                ammunition = {} -- В оружейке
            },

            -- Форматирование
            natoCode = '',
            fullRank = 'Разработчик',

            -- Вайтлист
            whitelist = true -- Может ли выдавать эту профу и менять звания
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_ADMIN, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    flag = 'ru',
    -- Стартовая
    start = false,
    -- Категория
    category = 'Администратор'
})

-- Не надо это трогать
START_TEAMS = {
	[TYPE_GAR] = TEAM_SURVIVOR,
}
