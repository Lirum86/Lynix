local currentGameId = tostring(game.PlaceId)

local gameScripts = {
    ['14236925335'] = 'Neighbors.lua',
    ['12699642568'] = 'Neighbors.lua', 
    ['136162036182779'] = 'Neighbors.lua',
    ['88728793053496'] = 'BuildCar.lua'
        ['123821081589134'] = 'BreakyourBones.lua'
}

if gameScripts[currentGameId] then
    pcall(function()
        loadstring(
            game:HttpGet(
                'https://raw.githubusercontent.com/Lirum86/Lynix/refs/heads/main/' .. gameScripts[currentGameId]
            )
        )()
    end)
end

pcall(function()
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/Lirum86/Lynix/refs/heads/main/Importent.lua'
        )
    )()
end)
