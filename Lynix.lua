local currentGameId = tostring(game.PlaceId)

local gameScripts = {
    ['14236925335'] = 'Neighbors.lua',
    ['12699642568'] = 'Neighbors.lua', 
    ['136162036182779'] = 'Neighbors.lua',
    ['88728793053496'] = 'BuildCar.lua',
    ['121864768012064'] = 'FischIt.lua',
    ['123821081589134'] = 'BreakyourBones.lua',
    ['3233893879'] = 'Badbusiness.lua',
    ['136801880565837'] = 'FPSFlick.lua',
    ['109265479748625'] = 'RepairaCar.lua',
    ['127822680964493'] = 'PrisonLiftClash.lua',
    ['77499336428083'] = 'DrawARaft.lua',
    ['96469185605358'] = 'AgeEvolutionTycoon.lua'
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
