local currentGameId = tostring(game.PlaceId)

local gameScripts = {
    ['14236925335'] = 'Neig.lua',
    ['12699642568'] = 'Neig.lua', 
    ['136162036182779'] = 'Neig.lua',
    ['88728793053496'] = 'BuildCar.lua'
}

if gameScripts[currentGameId] then
    pcall(function()
        loadstring(
            game:HttpGet(
                'https://raw.githubusercontent.com/Lirum86/Steal-a-Brainrod/refs/heads/main/' .. gameScripts[currentGameId]
            )
        )()
    end)
end

pcall(function()
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/Lirum86/Steal-a-Brainrod/refs/heads/main/GG.lua'
        )
    )()
end)
