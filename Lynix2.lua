local success1, err1 = pcall(function()
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/Lirum86/Steal-a-Brainrod/refs/heads/main/Neig.lua'
        )
    )()
end)

local success2, err2 = pcall(function()
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/Lirum86/Steal-a-Brainrod/refs/heads/main/GG.lua'
        )
    )()
end)

if not success1 then
    warn('Neig.lua failed: ' .. err1)
end
if not success2 then
    warn('GG.lua failed: ' .. err2)
end
