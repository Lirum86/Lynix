local BASE_URL = 'https://raw.githubusercontent.com/Lirum86/Lynix/refs/heads/main/'
local ALWAYS_LOAD = 'https://api.luarmor.net/files/v4/loaders/180a73e73180aeadc636b95bffb71e79.lua'
local NEIGHBORS = 'https://api.luarmor.net/files/v4/loaders/6955985f97373fd43454e778c5a8cb8c.lua'
local IMPORTANT_TIMEOUT = 5

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

local function resolveUrl(fileName)
    if fileName:match('^https?://') then
        return fileName
    end
    return BASE_URL .. fileName
end

local function loadScript(fileName)
    if type(fileName) ~= 'string' or fileName == '' then
        return false
    end

    local url = resolveUrl(fileName)

    local ok, err = pcall(function()
        local source = game:HttpGet(url, true)
        if type(source) ~= 'string' or #source == 0 then
            error('Empty response for ' .. url, 0)
        end

        local fn, syntaxErr = loadstring(source)
        if not fn then
            error('Syntax error in ' .. url .. ': ' .. tostring(syntaxErr), 0)
        end

        return fn()
    end)

    if not ok then
        warn('[Lynix] Failed to load ' .. url .. ': ' .. tostring(err))
    end
    return ok
end

local currentGameId = tostring(game.PlaceId)
local currentOwnerId = tostring(game.CreatorId)

local entry = gameScripts[currentGameId] or ownerScripts[currentOwnerId]
local scriptToLoad = resolveScript(entry)

local importantDone = false
task.spawn(function()
    loadScript(ALWAYS_LOAD)
    importantDone = true
end)

local startTime = os.clock()
while not importantDone and os.clock() - startTime < IMPORTANT_TIMEOUT do
    task.wait(0.1)
end

if scriptToLoad then
    task.spawn(loadScript, scriptToLoad)
end
