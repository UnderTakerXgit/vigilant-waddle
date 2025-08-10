-- Основные таблицы
NextRP.Jobs = {}
NextRP.Categories = {}
NextRP.CategoriesByName = {}
NextRP.JobsByID = {}

---- Типы
-- Новые
TYPE_NONE = 0
-- Фракции
TYPE_GAR = 1 -- Для ВАР
TYPE_JEDI = 2 -- Для Джедаев
TYPE_UNDEF = 3 -- Заготовка
TYPE_OTHER = 4 -- Для других отрядов
-- Администрация
TYPE_ADMIN = 10
-- РП Роль
TYPE_RPROLE = 11

---- Контролы
-- Союзники
CONTROL_GAR = 1 -- ВАР + Джедаи
-- Терористы
CONTROL_CIS = 2 -- КНС
-- Наёмники
CONTROL_HEADHUNTERS = 3 -- Наёмники
-- Ничего
CONTROL_NONE = 4 -- Ничего, не даёт эффекта на контролы

FACTION_LOCALIZATIONS = {
    [TYPE_NONE] = 'Без фракции',
    [TYPE_GAR] = 'Без фракции',
    [TYPE_JEDI] = 'B.S.A.A.',
    [TYPE_OTHER] = 'Umbrella Corp.',
    [TYPE_ADMIN] = 'Администратор',
    [TYPE_RPROLE] = 'РП Роль',
}

MONEY_FORMATS = { -- Не используеться сейчас
	[TYPE_NONE] = '%iCR',
    [TYPE_GAR] = '%iCR',
    [TYPE_JEDI] = '%iCR',
	[TYPE_ADMIN] = '%i админ баксов',
	[TYPE_OTHER] = '%iCR',
	[TYPE_RPROLE] = '%i роллов',
}

local indexnum = 0 -- счётчик для проф

function NextRP.createJob(sName, tTeam)
    indexnum = indexnum + 1

    team.SetUp( indexnum, sName, tTeam.color )

	tTeam.index = indexnum
	tTeam.name = sName or ''

	NextRP.Jobs[indexnum] = tTeam
	NextRP.JobsByID[tTeam.id] = tTeam

	local models = tTeam.model
	local rmodels = tTeam.ranks
	local fmodels = tTeam.flags

	if SERVER and models then
		if istable(models) then
			for k,v in pairs(models) do
				util.PrecacheModel(v)
			end
		else
			util.PrecacheModel(models)
		end

		if istable(rmodels) then
			for k, rank in pairs(rmodels) do
				if istable(rank.model) then
					for k, v in pairs(rank.model) do
						util.PrecacheModel(v)
					end
				else
					util.PrecacheModel(rank.model)
				end
			end
		end

		if istable(fmodels) then
			for k, flag in pairs(rmodels) do
				if istable(flag.model) then
					for k, v in pairs(flag.model) do
						util.PrecacheModel(v)
					end
				else
					util.PrecacheModel(flag.model)
				end 
			end
		end
	end

    hook.Run('NextRP::NewJob', indexnum, tTeam)
	MsgC('Зарегестрирована новая профессия ', '№', indexnum, ' "', sName, '", ', 'фракция: ', FACTION_LOCALIZATIONS[tTeam.type], '\n')

	if NextRP.CategoriesByName[tTeam.category] then
		local categId = NextRP.CategoriesByName[tTeam.category]

		NextRP.addJobToCateg(categId.index, tTeam)
	else
		local _, id = NextRP.createCategory(tTeam.category, {})
		NextRP.addJobToCateg(id, tTeam)

		MsgC('Зарегестрирована новая категория ', ' "', tTeam.category, '"\n')
	end

	return indexnum
end 

local indexnumcat = 0
function NextRP.createCategory(sName, tCateg)
	indexnumcat = indexnumcat + 1

	if NextRP.CategoriesByName[sName] then indexnumcat = NextRP.CategoriesByName[sName].index end

	local tReturn = {
		index = indexnumcat,
		name = sName,
		members = {},
		sortOrder = 999
	}

	table.Merge(tReturn, tCateg)

	NextRP.Categories[indexnumcat] = tReturn
	NextRP.CategoriesByName[sName] = tReturn

	return tReturn, indexnumcat
end

function NextRP.addJobToCateg(nId, tJob)
	local categ = NextRP.Categories[nId]
	local categ2 = NextRP.CategoriesByName[categ.name]

	local jobID = #categ.members

	categ.members[jobID + 1] = tJob
	categ2.members[jobID + 1] = tJob
end

function NextRP.GetSortedCategories()
	return SortedPairsByMemberValue( NextRP.Categories, 'sortOrder' )
end

function NextRP.GetJob(index)
    return NextRP.Jobs[index] or false
end

function NextRP.GetJobByName(name)
    for _, tblJob in pairs(NextRP.Jobs) do
		if tblJob.name == name then
			return tblJob
		end
	end
end

function NextRP.GetJobByID(name)
    for _, tblJob in pairs(NextRP.Jobs) do
		if tblJob.id == name then
			return tblJob
		end
	end
end

function NextRP.formatMoney(factionType, amount)
	return string.format(MONEY_FORMATS[factionType], amount)
end

local pMeta = FindMetaTable('Player')

function pMeta:getJobTable()
	return NextRP.GetJob(self:Team()) or false
end