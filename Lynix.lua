local BASE_URL = 'https://raw.githubusercontent.com/Lirum86/Lynix/refs/heads/main/'
local ALWAYS_LOAD = 'Importent.lua'

local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')

local function getPlatform()
    local okTenFoot, isTenFoot = pcall(function()
        return GuiService:IsTenFootInterface()
    end)
    if okTenFoot and isTenFoot then
        return 'Console'
    end

    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local mouse = UserInputService.MouseEnabled

    if touch and not keyboard and not mouse then
        return 'Mobile'
    end

    return 'PC'
end

local PLATFORM = getPlatform()

local NEIGHBORS = {
    Mobile = 'Neighbors.lua',
    PC = 'NeighboursNew.lua',
    Console = 'Neighbors.lua',
    Default = 'Neighbors.lua'
}

local gameScripts = {
    ['14236925335'] = NEIGHBORS,
    ['12699642568'] = NEIGHBORS,
    ['7333807183129'] = NEIGHBORS,
    ['136162036182779'] = NEIGHBORS,
    ['88728793053496'] = 'BuildCar.lua',
    ['121864768012064'] = 'FischIt.lua',
    ['123821081589134'] = 'BreakyourBones.lua',
    ['3233893879'] = 'Badbusiness.lua',
    ['136801880565837'] = 'FPSFlick.lua',
    ['109265479748625'] = 'RepairaCar.lua',
    ['127822680964493'] = 'PrisonLiftClash.lua',
    ['10518836988'] = 'LeaveCollect.lua',
    ['77499336428083'] = 'DrawARaft.lua',
    ['96469185605358'] = 'AgeEvolutionTycoon.lua'
}

local ownerScripts = {
    ['15109848'] = NEIGHBORS
}

local function resolveScript(entry)
    if type(entry) == 'string' then
        return entry
    elseif type(entry) == 'table' then
        return entry[PLATFORM] or entry.Default
    end
    return nil
end

local function loadScript(fileName)
    if type(fileName) ~= 'string' or fileName == '' then
        return false
    end

    local ok, err = pcall(function()
        local source = game:HttpGet(BASE_URL .. fileName, true)
        if type(source) ~= 'string' or #source == 0 then
            error('Empty response for ' .. fileName, 0)
        end

        local fn, syntaxErr = loadstring(source)
        if not fn then
            error('Syntax error in ' .. fileName .. ': ' .. tostring(syntaxErr), 0)
        end

        return fn()
    end)

    if not ok then
        warn('[Lynix] Failed to load ' .. fileName .. ': ' .. tostring(err))
    end
    return ok
end

local currentGameId = tostring(game.PlaceId)
local currentOwnerId = tostring(game.CreatorId)

local entry = gameScripts[currentGameId] or ownerScripts[currentOwnerId]
local scriptToLoad = resolveScript(entry)

if scriptToLoad then
    loadScript(scriptToLoad)
end

loadScript(ALWAYS_LOAD)
