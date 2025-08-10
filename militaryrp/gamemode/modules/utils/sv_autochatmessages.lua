local text = Color(255, 255, 255)
local blue = Color(71, 141, 255)
local yellow = Color(173, 255, 47)
local orange = Color(255, 50, 20)

local MESSAGES = {
    --{text, 'Надоело играть за этого персонажа? Используйте ', blue, 'F4', text, ' что-бы сменить его!'},
    {text, 'Хотите изменить частоту рации или кнопки для взаимодействия? Используйте для этого: ', blue, 'F2', text, '.'},
    {text, 'Кто-то нарушил? Используйте: ', blue, 'F7', text, ' что-бы подать жалобу.'},
    --{text, 'Для переключения вида от третьего лица, используйте: ', blue, 'F3', text, '.'},
    {text, 'За нарушение ', blue, 'правил вы можете ', text, 'получить наказание до ', orange, 'блокировки навсегда', text, '.'},
    {text, 'За новостями сообщества вы можете следить в ', yellow, 'Дискорд: ', blue, 'https://discord.gg/RQQmTj35ae', text, '.', yellow, '', blue, ''},
    --{text, 'Что-бы поддержать сервер вы можете ', blue, 'задонатить ', text, 'для этого используйте: ', blue, 'F6', text, ' или ', blue, '/donate', text, '.'},
}

if timer.Exists('NextRP::AutoChatMessages') then timer.Remove('NextRP::AutoChatMessages') end

timer.Create('NextRP::AutoChatMessages', 300, 0, function()
    NextRP:SendGlobalMessage(blue, 'Подсказка', text, ' | ', unpack(MESSAGES[math.random(1, #MESSAGES)]))
end)