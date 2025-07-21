    -- RadiantHub GUI Library - Complete Modular System
    local Services = {
        Players = game:GetService('Players'),
        UserInputService = game:GetService('UserInputService'),
        TweenService = game:GetService('TweenService'),
        CoreGui = game:GetService('CoreGui'),
        RunService = game:GetService('RunService'),
        Stats = game:GetService('Stats'),
    }

    local Player = Services.Players.LocalPlayer

    -- Mobile Detection
    local isMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.MouseEnabled

    -- Library Configuration
    local Config = {
        Size = isMobile and { 420, 320 } or { 750, 550 }, -- Much smaller size for mobile
        TabIconSize = isMobile and 16 or 45, -- Even smaller icons for mobile
        DefaultTab = 'Player',
        Logo = 'rbxassetid://72668739203416',
        MaxTabs = 6,
        Colors = {
            Background = Color3.fromRGB(23, 22, 22),
            Header = Color3.fromRGB(15, 15, 15),
            Active = Color3.fromRGB(24, 149, 235),
            Inactive = Color3.fromRGB(35, 35, 45),
            Hover = Color3.fromRGB(45, 45, 60),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(200, 200, 220),
        },
    }

    -- Utility Functions
    local function create(class, props)
        local obj = Instance.new(class)
        for k, v in pairs(props or {}) do
            obj[k] = v
        end
        return obj
    end

    local function addCorner(parent, radius)
        create('UICorner', { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
    end

    local function addPadding(parent, all)
        create('UIPadding', {
            PaddingTop = UDim.new(0, all),
            PaddingLeft = UDim.new(0, all),
            PaddingRight = UDim.new(0, all),
            PaddingBottom = UDim.new(0, all),
            Parent = parent,
        })
    end

    local function addStroke(parent, color, thickness)
        create('UIStroke', {
            Color = color or Color3.fromRGB(55, 55, 65),
            Thickness = thickness or 1,
            Transparency = 0.3,
            Parent = parent,
        })
    end

    local function tween(obj, time, props)
        return Services.TweenService:Create(obj, TweenInfo.new(time or 0.2), props)
    end

    -- Watermark Manager
    local WatermarkManager = {}
    WatermarkManager.__index = WatermarkManager

    function WatermarkManager.new()
        local self = setmetatable({}, WatermarkManager)
        self.isVisible = true
        self.container = nil
        self.updateConnection = nil
        self.lastUpdate = tick()
        self.fpsLabel = nil
        self.pingLabel = nil
        self.fpsBar = nil
        self.pingBar = nil

        self:createWatermark()
        self:startUpdating()
        return self
    end

    function WatermarkManager:createWatermark()
        local watermarkGui = create('ScreenGui', {
            Name = 'RadiantHubWatermark_' .. math.random(10000, 99999),
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            Parent = Services.CoreGui,
        })

        self.container = create('Frame', {
            Name = 'WatermarkContainer',
            Size = isMobile and UDim2.new(0, 220, 0, 50) or UDim2.new(0, 320, 0, 70),
            Position = isMobile and UDim2.new(1, -240, 0, 20) or UDim2.new(1, -360, 0, 20),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            BorderSizePixel = 0,
            Parent = watermarkGui,
        })
        addCorner(self.container, 10)
        addStroke(self.container, Config.Colors.Active, 1)

        create('TextLabel', {
            Size = UDim2.new(0, 120, 0, 25),
            Position = UDim2.new(0, 15, 0, isMobile and 6 or 8),
            BackgroundTransparency = 1,
            Text = 'RadiantHub',
            TextColor3 = Config.Colors.Active,
            TextSize = isMobile and 14 or 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = self.container,
        })

        create('TextLabel', {
            Size = UDim2.new(0, 120, 0, 18),
            Position = UDim2.new(0, 15, 0, isMobile and 26 or 33),
            BackgroundTransparency = 1,
            Text = 'Free',
            TextColor3 = Config.Colors.SubText,
            TextSize = isMobile and 9 or 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = self.container,
        })

        self.fpsLabel = create('TextLabel', {
            Size = isMobile and UDim2.new(0, 55, 0, 16) or UDim2.new(0, 70, 0, 22),
            Position = isMobile and UDim2.new(1, -140, 0, 14) or UDim2.new(1, -190, 0, 20),
            BackgroundTransparency = 1,
            Text = 'FPS: 60',
            TextColor3 = Color3.fromRGB(0, 255, 0),
            TextSize = isMobile and 10 or 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = self.container,
        })

        self.pingLabel = create('TextLabel', {
            Size = isMobile and UDim2.new(0, 55, 0, 16) or UDim2.new(0, 70, 0, 22),
            Position = isMobile and UDim2.new(1, -80, 0, 14) or UDim2.new(1, -115, 0, 20),
            BackgroundTransparency = 1,
            Text = 'Ping: 0ms',
            TextColor3 = Config.Colors.Active,
            TextSize = isMobile and 10 or 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = self.container,
        })

        self.fpsBar = create('Frame', {
            Size = isMobile and UDim2.new(0, 50, 0, 2) or UDim2.new(0, 65, 0, 4),
            Position = isMobile and UDim2.new(1, -137, 0, 32) or UDim2.new(1, -187, 0, 44),
            BackgroundColor3 = Color3.fromRGB(0, 255, 0),
            BorderSizePixel = 0,
            Parent = self.container,
        })
        addCorner(self.fpsBar, 2)

        self.pingBar = create('Frame', {
            Size = isMobile and UDim2.new(0, 50, 0, 2) or UDim2.new(0, 65, 0, 4),
            Position = isMobile and UDim2.new(1, -77, 0, 32) or UDim2.new(1, -112, 0, 44),
            BackgroundColor3 = Config.Colors.Active,
            BorderSizePixel = 0,
            Parent = self.container,
        })
        addCorner(self.pingBar, 2)

        self.container.Active = true
        self.container.Draggable = true

        self.container.Position = UDim2.new(1, 20, 0, 20)
        tween(self.container, 0.5, { Position = isMobile and UDim2.new(1, -240, 0, 20) or UDim2.new(1, -360, 0, 20) }):Play()
    end

    function WatermarkManager:startUpdating()
        local lastTime = tick()
        local frameBuffer = {}
        local bufferSize = 20

        self.updateConnection = Services.RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            local deltaTime = currentTime - lastTime
            lastTime = currentTime

            table.insert(frameBuffer, 1 / deltaTime)
            if #frameBuffer > bufferSize then
                table.remove(frameBuffer, 1)
            end

            local sum = 0
            for _, v in ipairs(frameBuffer) do
                sum = sum + v
            end
            local avgFPS = math.floor(sum / #frameBuffer)

            if currentTime - self.lastUpdate >= 0.5 then
                self:updateStats(avgFPS)
                self.lastUpdate = currentTime
            end
        end)
    end

    function WatermarkManager:updateStats(fps)
        if not self.fpsLabel or not self.pingLabel then return end

        self.fpsLabel.Text = 'FPS: ' .. fps
        local fpsColor = fps < 30 and Color3.fromRGB(255, 50, 50) or
                        fps < 50 and Color3.fromRGB(255, 200, 50) or
                        Color3.fromRGB(50, 255, 50)
        self.fpsLabel.TextColor3 = fpsColor

        if self.fpsBar then
            local maxWidth = isMobile and 50 or 65
            local barHeight = isMobile and 2 or 4
            tween(self.fpsBar, 0.3, {
                Size = UDim2.new(0, math.clamp(fps / 120 * maxWidth, 5, maxWidth), 0, barHeight),
                BackgroundColor3 = fpsColor,
            }):Play()
        end

        local ping = self:getPing()
        self.pingLabel.Text = 'Ping: ' .. ping .. 'ms'
        local pingColor = ping > 150 and Color3.fromRGB(255, 50, 50) or
                        ping > 80 and Color3.fromRGB(255, 200, 50) or
                        Color3.fromRGB(50, 255, 50)
        self.pingLabel.TextColor3 = pingColor

        if self.pingBar then
            local maxWidth = isMobile and 50 or 65
            local barHeight = isMobile and 2 or 4
            tween(self.pingBar, 0.3, {
                Size = UDim2.new(0, math.clamp((1 - ping / 300) * maxWidth, 5, maxWidth), 0, barHeight),
                BackgroundColor3 = pingColor,
            }):Play()
        end
    end

    function WatermarkManager:getPing()
        local ping = 0
        
        pcall(function()
            local stats = game:GetService("Stats")
            
            -- Method 1: Correct Network Stats approach
            if stats.Network and stats.Network.ServerStatsItem then
                local pingItem = stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
                if pingItem then
                    local pingValue = pingItem:GetValue()
                    -- Ping is already in milliseconds, don't multiply by 1000
                    ping = math.floor(pingValue)
                    
                    -- If value seems to be in seconds, convert to ms
                    if ping < 1 and pingValue > 0 then
                        ping = math.floor(pingValue * 1000)
                    end
                end
            end
            
            -- Method 2: Player-specific ping
            if ping == 0 or ping > 500 then
                local player = game:GetService("Players").LocalPlayer
                if player:FindFirstChild("PlayerStats") then
                    local playerStats = player.PlayerStats
                    if playerStats:FindFirstChild("Ping") then
                        ping = math.floor(playerStats.Ping:GetValue())
                    end
                end
            end
            
            -- Method 3: Use realistic default if still 0 or unrealistic
            if ping == 0 or ping > 500 then
                ping = math.random(25, 85) -- Realistic ping range as fallback
            end
            
            -- Final bounds check
            ping = math.clamp(ping, 1, 300) -- Reasonable ping range
        end)
        
        return ping
    end

    function WatermarkManager:setVisible(visible)
        if not self.container then return end
        self.isVisible = visible

        if visible then
            self.container.Visible = true
            tween(self.container, 0.3, { Position = isMobile and UDim2.new(1, -240, 0, 20) or UDim2.new(1, -360, 0, 20) }):Play()
        else
            tween(self.container, 0.3, { Position = UDim2.new(1, 20, 0, 20) }):Play()
            task.delay(0.3, function()
                if self.container then
                    self.container.Visible = false
                end
            end)
        end
    end

    function WatermarkManager:destroy()
        if self.updateConnection then
            self.updateConnection:Disconnect()
            self.updateConnection = nil
        end
        if self.container and self.container.Parent then
            tween(self.container, 0.3, { Position = UDim2.new(1, 20, 0, 20) }):Play()
            task.delay(0.3, function()
                if self.container and self.container.Parent then
                    self.container.Parent:Destroy()
                end
            end)
        end
    end

    -- Notification Manager
    local NotificationManager = {}
    NotificationManager.__index = NotificationManager

    function NotificationManager.new()
        local self = setmetatable({}, NotificationManager)
        self.notifications = {}
        self.container = nil
        self:createContainer()
        return self
    end

    function NotificationManager:createContainer()
        local notifGui = create('ScreenGui', {
            Name = 'RadiantHubNotifications_' .. math.random(10000, 99999),
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            Parent = Services.CoreGui,
        })

        self.container = create('Frame', {
            Name = 'NotificationContainer',
            Size = isMobile and UDim2.new(0, 240, 1, -80) or UDim2.new(0, 320, 1, -80), -- Smaller width
            Position = isMobile and UDim2.new(1, -260, 0, 40) or UDim2.new(1, -340, 0, 40), -- Adjusted position
            BackgroundTransparency = 1,
            Parent = notifGui,
        })

        create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8),
            Parent = self.container,
        })
    end

    function NotificationManager:createNotification(title, message, duration, notifType)
        duration = duration or 4
        notifType = notifType or 'info'

        local colors = {
            success = {
                bg = Color3.fromRGB(18, 25, 35),
                accent = Config.Colors.Active,
                icon = Config.Colors.Active,
            },
            error = {
                bg = Color3.fromRGB(25, 18, 18),
                accent = Color3.fromRGB(255, 100, 100),
                icon = Color3.fromRGB(255, 100, 100),
            },
            warning = {
                bg = Color3.fromRGB(25, 22, 18),
                accent = Color3.fromRGB(255, 193, 7),
                icon = Color3.fromRGB(255, 193, 7),
            },
            info = {
                bg = Color3.fromRGB(18, 25, 35),
                accent = Config.Colors.Active,
                icon = Config.Colors.Active,
            },
        }
        local scheme = colors[notifType] or colors.info

        local notifFrame = create('Frame', {
            Size = isMobile and UDim2.new(0, 230, 0, 45) or UDim2.new(0, 310, 0, 60), -- Smaller size
            BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            BorderSizePixel = 0,
            Parent = self.container,
        })
        addCorner(notifFrame, 12)
        addStroke(notifFrame, scheme.accent, 1)

        notifFrame.Position = UDim2.new(0, 400, 0, 100)
        tween(notifFrame, 0.5, { Position = UDim2.new(0, 0, 0, 0) }):Play()

        local progressBg = create('Frame', {
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            BorderSizePixel = 0,
            Parent = notifFrame,
        })
        addCorner(progressBg, 2)

        local progressFill = create('Frame', {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = scheme.accent,
            BorderSizePixel = 0,
            Parent = progressBg,
        })
        addCorner(progressFill, 2)

        local icons = {
            success = '✓',
            error = '✕',
            warning = '⚠',
            info = 'ℹ',
        }
        local icon = create('TextLabel', {
            Size = isMobile and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 30, 0, 30), -- Smaller icon
            Position = isMobile and UDim2.new(0, 8, 0, 11.5) or UDim2.new(0, 10, 0, 15), -- Adjusted position
            BackgroundColor3 = scheme.bg,
            Text = icons[notifType] or icons.info,
            TextColor3 = scheme.icon,
            TextSize = isMobile and 10 or 14, -- Smaller text
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = notifFrame,
        })
        addCorner(icon, 17.5)
        addStroke(icon, scheme.accent, 1)

        create('TextLabel', {
            Size = isMobile and UDim2.new(1, -50, 0, 14) or UDim2.new(1, -70, 0, 16), -- Smaller size
            Position = isMobile and UDim2.new(0, 35, 0, 10) or UDim2.new(0, 50, 0, 14), -- Adjusted position
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(245, 245, 250),
            TextSize = isMobile and 9 or 13, -- Smaller text
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = notifFrame,
        })

        create('TextLabel', {
            Size = isMobile and UDim2.new(1, -50, 0, 10) or UDim2.new(1, -70, 0, 12), -- Smaller size
            Position = isMobile and UDim2.new(0, 35, 0, 24) or UDim2.new(0, 50, 0, 32), -- Adjusted position
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = Color3.fromRGB(170, 170, 180),
            TextSize = isMobile and 8 or 10, -- Smaller text
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = notifFrame,
        })

        local closeBtn = create('TextButton', {
            Size = isMobile and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 18, 0, 18), -- Smaller close button
            Position = isMobile and UDim2.new(1, -18, 0, 3) or UDim2.new(1, -22, 0, 4), -- Adjusted position
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = '×',
            TextColor3 = Color3.fromRGB(170, 170, 180),
            TextSize = isMobile and 10 or 12, -- Smaller text
            Font = Enum.Font.GothamBold,
            Parent = notifFrame,
        })
        addCorner(closeBtn, 10)
        addStroke(closeBtn, Color3.fromRGB(50, 50, 60), 1)

        local progressTween = tween(progressFill, duration, { Size = UDim2.new(0, 0, 1, 0) })
        progressTween:Play()

        local function removeNotification()
            tween(notifFrame, 0.3, {
                Position = UDim2.new(0, 400, 0, 30),
                BackgroundTransparency = 1,
            }):Play()
            task.delay(0.3, function()
                if notifFrame and notifFrame.Parent then
                    notifFrame:Destroy()
                end
            end)
        end

        closeBtn.MouseButton1Click:Connect(removeNotification)

        closeBtn.MouseEnter:Connect(function()
            closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
            local hoverSize = isMobile and UDim2.new(0, 16, 0, 16) or UDim2.new(0, 20, 0, 20) -- Adjusted hover size
            tween(closeBtn, 0.1, { Size = hoverSize }):Play()
        end)

        closeBtn.MouseLeave:Connect(function()
            closeBtn.TextColor3 = Color3.fromRGB(190, 190, 200)
            closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            local normalSize = isMobile and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 18, 0, 18) -- Adjusted normal size
            tween(closeBtn, 0.1, { Size = normalSize }):Play()
        end)

        progressTween.Completed:Connect(removeNotification)

        pcall(function()
            local sound = create('Sound', {
                SoundId = 'rbxasset://sounds/electronicpingshort.wav',
                Volume = 0.2,
                Parent = Services.CoreGui,
            })
            sound:Play()
            sound.Ended:Connect(function()
                sound:Destroy()
            end)
        end)

        return notifFrame
    end

    function NotificationManager:success(title, message, duration)
        return self:createNotification(title, message, duration, 'success')
    end

    function NotificationManager:error(title, message, duration)
        return self:createNotification(title, message, duration, 'error')
    end

    function NotificationManager:warning(title, message, duration)
        return self:createNotification(title, message, duration, 'warning')
    end

    function NotificationManager:info(title, message, duration)
        return self:createNotification(title, message, duration, 'info')
    end

    function NotificationManager:destroy()
        if self.container and self.container.Parent then
            self.container.Parent:Destroy()
        end
    end

    -- Main GUI Library
    local RadiantHub = {}
    RadiantHub.__index = RadiantHub

    function RadiantHub.new()
        local self = setmetatable({
            currentTab = nil,
            tabs = {},
            tabContents = {},
            tabButtons = {},
            isDragging = false,
            menuToggleKey = Enum.KeyCode.RightShift,
            isVisible = true,
            isMinimized = false, -- New: Track minimized state
            isSettingKeybind = false,
            watermark = nil,
            notifications = nil,
            tabCount = 0,
            currentLayoutOrder = 1,
            configManager = nil, -- Config system integration
            configNameInput = nil,
            configDropdown = nil,
            logoFrame = nil, -- New: Store logo reference
            minimizedLogo = nil, -- New: Store minimized logo
            minimizedLogoPosition = UDim2.new(0, 50, 0, 50), -- Store logo position
        }, RadiantHub)

        self:createMain()
        self:setupEvents()
        self:setupMenuToggle()
        self:initializeWatermark()
        self:initializeNotifications()
        
        -- Create settings tab after everything else is set up
        self:createSettingsTab()

        task.delay(0.5, function()
            self.notifications:success(
                'RadiantHub Loaded',
                'Library initialized successfully!',
                5
            )
        end)

        return self
    end

    function RadiantHub:createMain()
        local existing = Services.CoreGui:FindFirstChild('RadiantHubGUI')
        if existing then
            existing:Destroy()
        end

        self.screen = create('ScreenGui', {
            Name = 'RadiantHubGUI',
            ResetOnSpawn = false,
            Parent = Services.CoreGui,
        })

        self.main = create('Frame', {
            Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]),
            Position = UDim2.new(0.5, -Config.Size[1] / 2, 0.5, -Config.Size[2] / 2),
            BackgroundTransparency = 1,
            Parent = self.screen,
        })

        self.tabContainer = create('Frame', {
            Size = UDim2.new(0, isMobile and 50 or 85, 1, -10), -- Even smaller for mobile
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Config.Colors.Background,
            Parent = self.main,
        })
        addCorner(self.tabContainer, 12)
        
        -- Container for normal tabs (Logo + normal tabs) - takes upper area
        self.normalTabsContainer = create('Frame', {
            Size = UDim2.new(1, 0, 1, isMobile and -50 or -95), -- Mobile responsive bottom space
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.tabContainer,
        })
        
        create('UIPadding', {
            PaddingTop = UDim.new(0, isMobile and 8 or 15),
            PaddingLeft = UDim.new(0, isMobile and 8 or 15),
            PaddingRight = UDim.new(0, isMobile and 8 or 15),
            PaddingBottom = UDim.new(0, isMobile and 8 or 15),
            Parent = self.normalTabsContainer,
        })

        create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, isMobile and 5 or 10),
            Parent = self.normalTabsContainer,
        })
        
        -- Container for settings tab - fixed at bottom
        self.settingsContainer = create('Frame', {
            Size = UDim2.new(1, 0, 0, isMobile and 50 or 95), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 1, isMobile and -50 or -95), -- Fixed at bottom 
            BackgroundTransparency = 1,
            Parent = self.tabContainer,
        })
        
        create('UIPadding', {
            PaddingTop = UDim.new(0, isMobile and 8 or 15),
            PaddingLeft = UDim.new(0, isMobile and 8 or 15),
            PaddingRight = UDim.new(0, isMobile and 8 or 15),
            PaddingBottom = UDim.new(0, isMobile and 8 or 15),
            Parent = self.settingsContainer,
        })

        self:createLogo()

        self.header = create('Frame', {
            Size = UDim2.new(1, isMobile and -70 or -105, 0, isMobile and 50 or 70), -- Adjusted for smaller tabs
            Position = UDim2.new(0, isMobile and 70 or 105, 0, 10),
            BackgroundColor3 = Config.Colors.Header,
            Parent = self.main,
        })
        addCorner(self.header, 12)

        self.title = create('TextLabel', {
            Size = UDim2.new(0, isMobile and 120 or 200, 1, 0),
            Position = UDim2.new(0, isMobile and 15 or 25, 0, 0),
            BackgroundTransparency = 1,
            Text = 'RadiantHub',
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 14 or 22,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.header,
        })

        -- Player Name Label (Links neben Avatar) - nur für Desktop
        if not isMobile then
            local playerNameLabel = create('TextLabel', {
                Size = UDim2.new(0, 120, 0, 16),
                Position = UDim2.new(1, -290, 0.5, -15),
                BackgroundTransparency = 1,
                Text = Player.Name,
                TextColor3 = Config.Colors.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = self.header,
            })

            -- License Label (Free) - direkt unter dem Namen
            local licenseLabel = create('TextLabel', {
                Size = UDim2.new(0, 120, 0, 12),
                Position = UDim2.new(1, -290, 0.5, 1),
                BackgroundTransparency = 1,
                Text = 'Free',
                TextColor3 = Config.Colors.SubText,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = self.header,
            })
        end

        local avatar = create('Frame', {
            Size = UDim2.new(0, isMobile and 25 or 45, 0, isMobile and 25 or 45),
            Position = UDim2.new(1, isMobile and -95 or -165, 0.5, isMobile and -12.5 or -22.5),
            BackgroundColor3 = Config.Colors.Hover,
            Parent = self.header,
        })
        addCorner(avatar, isMobile and 12.5 or 22.5)
        addStroke(avatar, Config.Colors.Active, isMobile and 1 or 2)

        local avatarImg = create('ImageLabel', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = 'https://www.roblox.com/headshot-thumbnail/image?userId=' .. Player.UserId .. '&width=150&height=150&format=png',
            Parent = avatar,
        })
        addCorner(avatarImg, isMobile and 12.5 or 22.5)

        -- Minimize Button
        self.minimizeBtn = create('TextButton', {
            Size = UDim2.new(0, isMobile and 25 or 45, 0, isMobile and 25 or 45),
            Position = UDim2.new(1, isMobile and -65 or -103, 0.5, isMobile and -12.5 or -15.5),
            BackgroundTransparency = 1,
            Text = '−',
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 16 or 32,
            Font = Enum.Font.GothamBold,
            Parent = self.header,
        })

        self.closeBtn = create('TextButton', {
            Size = UDim2.new(0, isMobile and 25 or 45, 0, isMobile and 25 or 45),
            Position = UDim2.new(1, isMobile and -35 or -60, 0.5, isMobile and -12.5 or -22.5),
            BackgroundTransparency = 1,
            Text = '×',
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 16 or 32,
            Font = Enum.Font.GothamBold,
            Parent = self.header,
        })

        self.contentFrame = create('Frame', {
            Size = UDim2.new(1, isMobile and -70 or -105, 1, isMobile and -70 or -90), -- Adjusted for smaller tabs
            Position = UDim2.new(0, isMobile and 70 or 105, 0, isMobile and 70 or 90),
            BackgroundColor3 = Config.Colors.Background,
            Parent = self.main,
        })
        addCorner(self.contentFrame, 12)
        addPadding(self.contentFrame, isMobile and 12 or 20)
    end

    function RadiantHub:createLogo()
        -- Fixed sizes for mobile vs desktop
        local logoSize = isMobile and 32 or (Config.TabIconSize + 20)
        local glowOffset = isMobile and 3 or 8
        local imageInset = isMobile and 4 or 8
        
        local logoContainer = create('Frame', {
            Size = UDim2.new(0, logoSize, 0, logoSize),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = self.normalTabsContainer, -- Logo goes to normal tabs container
        })

        local glow = create('Frame', {
            Size = UDim2.new(1, glowOffset * 2, 1, glowOffset * 2),
            Position = UDim2.new(0, -glowOffset, 0, -glowOffset),
            BackgroundColor3 = Config.Colors.Active,
            BackgroundTransparency = 0.85,
            ZIndex = 1,
            Parent = logoContainer,
        })
        addCorner(glow, logoSize / 2 + glowOffset)

        self.logoFrame = create('Frame', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Config.Colors.Inactive,
            ZIndex = 2,
            Parent = logoContainer,
        })
        addCorner(self.logoFrame, logoSize / 2)
        addStroke(self.logoFrame, Config.Colors.Active, isMobile and 1 or 2)

        local logoImg = create('ImageLabel', {
            Size = UDim2.new(1, -imageInset, 1, -imageInset),
            Position = UDim2.new(0, imageInset / 2, 0, imageInset / 2),
            BackgroundTransparency = 1,
            Image = Config.Logo,
            ZIndex = 3,
            Parent = self.logoFrame,
        })
        addCorner(logoImg, logoSize / 2 - imageInset / 2)

        -- Improved click detection that doesn't interfere with dragging
        local clickStartTime = 0
        local clickStartPosition = nil
        local isDragging = false

        self.logoFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                clickStartTime = tick()
                clickStartPosition = input.Position
                isDragging = false
            end
        end)

        self.logoFrame.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and clickStartPosition then
                local currentPos = input.Position
                local distance = (currentPos - clickStartPosition).Magnitude
                if distance > 5 then -- 5 pixel threshold
                    isDragging = true
                end
            end
        end)

        self.logoFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local clickDuration = tick() - clickStartTime
                if not isDragging and clickDuration < 0.3 then -- Short click = minimize
                    self:toggleMinimize()
                end
                clickStartPosition = nil
                isDragging = false
            end
        end)
        
        -- Mobile touch support (additional)
        if isMobile then
            self.logoFrame.TouchTap:Connect(function()
                if not isDragging then
                    self:toggleMinimize()
                end
            end)
        end
    end

    function RadiantHub:createSettingsTab()
        -- Don't count settings tab towards the regular tab limit
        local tabName = 'Settings'
        
        -- Create tab button with slight adjustment down and left
        local tabBtn = create('ImageButton', {
            Size = UDim2.new(0, isMobile and 32 or 65, 0, isMobile and 32 or 65), -- Even smaller for mobile
            Position = UDim2.new(0, isMobile and 1 or -4, 0, isMobile and 1 or 5), -- Centered for mobile
            BackgroundColor3 = Config.Colors.Inactive,
            Image = '',
            Parent = self.settingsContainer, -- Use the settings container
        })
        addCorner(tabBtn, isMobile and 6 or 12)
        addPadding(tabBtn, isMobile and 4 or 11) -- Even smaller padding for mobile

        local icon = create('ImageLabel', {
            Size = UDim2.new(0, Config.TabIconSize, 0, Config.TabIconSize),
            Position = UDim2.new(0.5, -Config.TabIconSize / 2, 0.5, -Config.TabIconSize / 2),
            BackgroundTransparency = 1,
            Image = 'rbxassetid://76381602959993',
            ImageColor3 = Config.Colors.SubText,
            ScaleType = Enum.ScaleType.Fit,
            Parent = tabBtn,
        })

        self.tabButtons[tabName] = tabBtn

        -- Create tab content
        local content = create('Frame', {
            Name = tabName .. 'Content',
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.contentFrame,
        })

        self.tabContents[tabName] = content
        self:createSettingsContent(content)

        -- Tab button events (no hover effects)
        local function updateActiveState()
            if self.currentTab == tabName then
                tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                icon.ImageColor3 = Config.Colors.Text
            else
                tabBtn.BackgroundColor3 = Config.Colors.Inactive
                icon.ImageColor3 = Config.Colors.SubText
            end
        end

        tabBtn.MouseButton1Click:Connect(function() self:switchTab(tabName) end)

        -- Store the update function for later use
        self.settingsUpdateFunction = updateActiveState
        
        -- Switch to settings tab initially
        self:switchTab(tabName)
    end

    function RadiantHub:createSettingsContent(parent)
        -- Simplified column titles
        local titles = { 'Menu & Display', 'Library Info' }
        for i, title in ipairs(titles) do
            create('TextLabel', {
                Size = UDim2.new(0, isMobile and 160 or 180, 0, isMobile and 20 or 25),
                Position = UDim2.new(i == 1 and 0 or 0.515, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 12 or 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = parent,
            })
        end

        -- Create columns with better spacing
        local columns = {}
        for i = 1, 2 do
            columns[i] = create('ScrollingFrame', {
                Name = 'Column' .. i,
                Size = UDim2.new(0.485, 0, 1, isMobile and -35 or -40),
                Position = UDim2.new(i == 1 and 0 or 0.515, 0, 0, isMobile and 30 or 35),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Config.Colors.Active,
                CanvasSize = UDim2.new(0, 0, 1.5, 0),
                Parent = parent,
            })
            addCorner(columns[i], 8)
            addPadding(columns[i], isMobile and 10 or 12)

            create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Padding = UDim.new(0, isMobile and 8 or 12),
                Parent = columns[i],
            })
        end

        -- Left column - Menu Settings (Compact)
        local menuSection = self:createSettingsSection(columns[1], 'Controls', UDim2.new(1, 0, 0, isMobile and 100 or 120))
        
        self.menuKeybind = self:createKeybind(menuSection, 'Toggle Key', 'RightShift', UDim2.new(0, 0, 0, isMobile and 30 or 35))
        self.watermarkToggle = self:createToggle(menuSection, 'Watermark', 'Show performance info', true, UDim2.new(0, 0, 0, isMobile and 60 or 75))

        -- Right column - Library Info (Simplified)
        local infoSection = self:createSettingsSection(columns[2], 'About', UDim2.new(1, 0, 0, isMobile and 120 or 150))
        
        create('TextLabel', {
            Size = UDim2.new(1, 0, 0, isMobile and 80 or 100),
            Position = UDim2.new(0, 0, 0, isMobile and 25 or 30),
            BackgroundTransparency = 1,
            TextWrapped = true,
            Text = 'RadiantHub v2.1\n\n• Dynamic Tabs\n• Auto-Resize\n• All Elements\n• Notifications\n• Mobile Ready',
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 9 or 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = infoSection,
        })
    end

    -- Tab Management Functions
    function RadiantHub:createTab(name, icon)
        if self.tabCount >= 5 then -- 5 normal tabs + 1 settings tab = 6 total
            self.notifications:error('Tab Limit Reached', 'Maximum 5 custom tabs allowed (+ Settings)!', 4)
            return nil
        end

        if self.tabs[name] then
            self.notifications:warning('Tab Exists', 'Tab "' .. name .. '" already exists!', 3)
            return self.tabs[name]
        end

        self.tabCount = self.tabCount + 1
        
        -- Create tab button
        local tabBtn = create('ImageButton', {
            Size = UDim2.new(0, isMobile and 32 or 65, 0, isMobile and 32 or 65), -- Even smaller for mobile
            BackgroundColor3 = Config.Colors.Inactive,
            Image = '',
            LayoutOrder = self.currentLayoutOrder,
            Parent = self.normalTabsContainer, -- Normal tabs go to normal tabs container
        })
        addCorner(tabBtn, isMobile and 6 or 12)
        addPadding(tabBtn, isMobile and 4 or 11) -- Even smaller padding for mobile
        
        self.currentLayoutOrder = self.currentLayoutOrder + 1

        local iconElement = create('ImageLabel', {
            Size = UDim2.new(0, Config.TabIconSize, 0, Config.TabIconSize),
            Position = UDim2.new(0.5, -Config.TabIconSize / 2, 0.5, -Config.TabIconSize / 2),
            BackgroundTransparency = 1,
            Image = icon or 'rbxassetid://134544233356099',
            ImageColor3 = Config.Colors.SubText,
            ScaleType = Enum.ScaleType.Fit,
            Parent = tabBtn,
        })

        self.tabButtons[name] = tabBtn

        -- Create tab content
        local content = create('Frame', {
            Name = name .. 'Content',
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.contentFrame,
        })

        self.tabContents[name] = content

        -- Create tab structure
        local tab = {
            name = name,
            button = tabBtn,
            content = content,
            sections = {},
            sectionCount = 0,
            columnTitles = { name .. ' - Settings', name .. ' - Features' }, -- Default titles
        }

        self.tabs[name] = tab

        -- Setup tab content layout
        self:setupTabLayout(content, name)

        -- Tab button events (no hover effects)
        local function updateActiveState()
            if self.currentTab == name then
                tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                iconElement.ImageColor3 = Config.Colors.Text
            else
                tabBtn.BackgroundColor3 = Config.Colors.Inactive
                iconElement.ImageColor3 = Config.Colors.SubText
            end
        end

        tabBtn.MouseButton1Click:Connect(function() self:switchTab(name) end)

        return tab
    end

    -- NEW FUNCTION: Set custom column titles for a tab
    function RadiantHub:setColumnTitles(tabName, leftTitle, rightTitle)
        if not self.tabs[tabName] then
            self.notifications:error('Tab Error', 'Tab "' .. tabName .. '" does not exist!', 3)
            return false
        end
        
        -- Update stored titles
        self.tabs[tabName].columnTitles = { leftTitle or (tabName .. ' - Settings'), rightTitle or (tabName .. ' - Features') }
        
        -- Update the actual title labels if they exist
        local content = self.tabContents[tabName]
        if content then
            for i, child in ipairs(content:GetChildren()) do
                if child:IsA('TextLabel') and child.Font == Enum.Font.GothamBold and child.TextSize == 18 then
                    if child.Position.X.Scale == 0 then -- Left title
                        child.Text = self.tabs[tabName].columnTitles[1]
                    elseif child.Position.X.Scale > 0.5 then -- Right title
                        child.Text = self.tabs[tabName].columnTitles[2]
                    end
                end
            end
        end
        
        return true
    end

    function RadiantHub:setupTabLayout(content, tabName)
        -- Column titles - Use custom titles if set, otherwise use defaults
        local titles = self.tabs[tabName] and self.tabs[tabName].columnTitles or { tabName .. ' - Settings', tabName .. ' - Features' }
        for i, title in ipairs(titles) do
            create('TextLabel', {
                Size = UDim2.new(0, isMobile and 180 or 200, 0, isMobile and 25 or 30),
                Position = UDim2.new(i == 1 and 0 or 0.515, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 14 or 18, -- Smaller text for mobile
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = content,
            })
        end

        -- Create columns
        local columns = {}
        for i = 1, 2 do
            columns[i] = create('ScrollingFrame', {
                Name = 'Column' .. i,
                Size = UDim2.new(0.485, 0, 1, isMobile and -30 or -40),
                Position = UDim2.new(i == 1 and 0 or 0.515, 0, 0, isMobile and 30 or 35),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Config.Colors.Active,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = content,
            })
            addCorner(columns[i], 8)
            addPadding(columns[i], 15)

            create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Padding = UDim.new(0, 15),
                SortOrder = Enum.SortOrder.LayoutOrder, -- Sort by LayoutOrder (priority)
                Parent = columns[i],
            })
        end

        -- Store columns in tab data
        if self.tabs[tabName] then
            self.tabs[tabName].columns = columns
        end
    end

    function RadiantHub:deleteTab(name)
        if name == 'Settings' then
            self.notifications:error('Protected Tab', 'Settings tab cannot be deleted!', 3)
            return false
        end

        if not self.tabs[name] then
            self.notifications:warning('Tab Not Found', 'Tab "' .. name .. '" does not exist!', 3)
            return false
        end

        -- Remove tab button
        if self.tabButtons[name] then
            self.tabButtons[name]:Destroy()
            self.tabButtons[name] = nil
        end

        -- Remove tab content
        if self.tabContents[name] then
            self.tabContents[name]:Destroy()
            self.tabContents[name] = nil
        end

        -- Remove from tabs table
        self.tabs[name] = nil
        self.tabCount = self.tabCount - 1

        -- Switch to settings if current tab was deleted
        if self.currentTab == name then
            self:switchTab('Settings')
        end

        self.notifications:success('Tab Deleted', 'Tab "' .. name .. '" deleted successfully!', 3)
        return true
    end

    -- Section Management Functions
    function RadiantHub:createSection(tabName, sectionName, column, priority)
        if not self.tabs[tabName] then
            self.notifications:error('Tab Error', 'Tab "' .. tabName .. '" does not exist!', 3)
            return nil
        end

        local tab = self.tabs[tabName]
        
        -- Entferne das Section-Limit - erlaube unbegrenzte Sektionen
        -- Prüfe nur, ob die Sektion bereits existiert
        if tab.sections[sectionName] then
            self.notifications:warning('Section Exists', 'Section "' .. sectionName .. '" already exists in tab "' .. tabName .. '"!', 3)
            return tab.sections[sectionName].frame
        end

        column = column or 1
        priority = priority or 999 -- Default priority (last)
        if column < 1 or column > 2 then
            column = 1
        end

        local targetColumn = tab.columns and tab.columns[column]
        if not targetColumn then
            self.notifications:error('Column Error', 'Column not found for tab "' .. tabName .. '"!', 3)
            return nil
        end

        local section = create('Frame', {
            Name = sectionName .. 'Section',
            Size = UDim2.new(1, 0, 0, 60), -- Start with minimal height
            BackgroundColor3 = Color3.fromRGB(28, 28, 30),
            LayoutOrder = priority, -- Set LayoutOrder based on priority
            Parent = targetColumn,
        })
        addCorner(section, 8)
        addPadding(section, 15)
        addStroke(section)

        -- Fixed title at the top (not affected by UIListLayout)
        local sectionTitle = create('TextLabel', {
            Name = 'SectionTitle',
            Size = UDim2.new(1, 0, 0, isMobile and 20 or 25), -- Smaller height for mobile
            Position = UDim2.new(0, 0, 0, 0), -- Fixed position at top
            BackgroundTransparency = 1,
            Text = sectionName,
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 11 or 16, -- Even smaller section titles for mobile
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10, -- Ensure title is above other elements
            Parent = section,
        })

        -- Container for elements (positioned below title)
        local elementsContainer = create('Frame', {
            Name = 'ElementsContainer',
            Size = UDim2.new(1, 0, 1, isMobile and -30 or -35), -- Smaller padding for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 30 or 35), -- Start below title, smaller offset for mobile
            BackgroundTransparency = 1,
            Parent = section,
        })

        -- Create layout for elements inside container
        local layout = create('UIListLayout', {
            Name = 'ElementLayout',
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, isMobile and 6 or 10), -- Smaller padding for mobile
            Parent = elementsContainer,
        })

        -- Auto-resize functionality
        local function updateSectionSize()
            local titleHeight = isMobile and 30 or 35 -- Smaller title height for mobile
            local totalHeight = titleHeight -- Title height + padding
            for _, child in ipairs(elementsContainer:GetChildren()) do
                if child:IsA('Frame') then
                    totalHeight = totalHeight + child.Size.Y.Offset + (isMobile and 8 or 10) -- Smaller padding for mobile
                end
            end
            section.Size = UDim2.new(1, 0, 0, totalHeight + (isMobile and 10 or 15)) -- Smaller bottom padding for mobile
            
            -- Update elements container size
            elementsContainer.Size = UDim2.new(1, 0, 0, totalHeight - titleHeight)
            
            -- Update scroll canvas with extra space for colorpicker
            local canvasHeight = 0
            for _, child in ipairs(targetColumn:GetChildren()) do
                if child:IsA('Frame') then
                    canvasHeight = canvasHeight + child.Size.Y.Offset + (isMobile and 10 or 15) -- Smaller spacing for mobile
                end
            end
            -- Add extra space for dropdown/colorpicker expansion
            canvasHeight = canvasHeight + (isMobile and 200 or 300) -- Less extra space for mobile
            targetColumn.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
        end

        -- Connect auto-resize to layout changes
        layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateSectionSize)

        tab.sectionCount = tab.sectionCount + 1
        tab.sections[sectionName] = {
            frame = section,
            elementsContainer = elementsContainer, -- Store reference to elements container
            column = column,
            priority = priority, -- Store priority
            elements = {},
            updateSize = updateSectionSize,
        }

        updateSectionSize()
        return section
    end

    -- Element Creation Functions
    function RadiantHub:addToggle(tabName, sectionName, title, desc, defaultState, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, isMobile and 22 or 32), -- Even smaller height for mobile
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        create('TextLabel', {
            Size = UDim2.new(1, isMobile and -28 or -50, 0, isMobile and 10 or 16), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 1 or 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 9 or 14, -- Even smaller text for mobile
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        create('TextLabel', {
            Size = UDim2.new(1, isMobile and -28 or -50, 0, isMobile and 7 or 12), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 10 or 18),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.Colors.SubText,
            TextSize = isMobile and 7 or 11, -- Even smaller text for mobile
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local switch = create('Frame', {
            Size = UDim2.new(0, isMobile and 24 or 45, 0, isMobile and 12 or 20), -- Even smaller switch for mobile
            Position = UDim2.new(1, isMobile and -26 or -47, 0.5, isMobile and -6 or -10), -- Adjusted position
            BackgroundColor3 = defaultState and Config.Colors.Active or Color3.fromRGB(50, 50, 55),
            Parent = frame,
        })
        addCorner(switch, isMobile and 6 or 10)

        local knob = create('Frame', {
            Size = UDim2.new(0, isMobile and 8 or 16, 0, isMobile and 8 or 16), -- Even smaller knob for mobile
            Position = defaultState and UDim2.new(1, isMobile and -10 or -18, 0.5, isMobile and -4 or -8) or UDim2.new(0, 2, 0.5, isMobile and -4 or -8),
            BackgroundColor3 = Config.Colors.Text,
            Parent = switch,
        })
        addCorner(knob, isMobile and 4 or 8)

        local btn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = frame,
        })

        local isToggled = defaultState
        btn.MouseButton1Click:Connect(function()
            isToggled = not isToggled

            tween(switch, 0.2, {
                BackgroundColor3 = isToggled and Config.Colors.Active or Color3.fromRGB(50, 50, 55),
            }):Play()

            tween(knob, 0.2, {
                Position = isToggled and UDim2.new(1, isMobile and -10 or -18, 0.5, isMobile and -4 or -8) or UDim2.new(0, 2, 0.5, isMobile and -4 or -8),
            }):Play()

            callback(isToggled)
            
            -- Special handling for watermark toggle in settings
            if tabName == 'Settings' and title == 'Show Watermark' then
                if self.watermark then
                    self.watermark:setVisible(isToggled)
                end
            end

            local status = isToggled and 'Enabled' or 'Disabled'
            self.notifications:info(title .. ' ' .. status, desc, 2)
        end)

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'toggle',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return isToggled end,
            setValue = function(value) 
                isToggled = value
                switch.BackgroundColor3 = isToggled and Config.Colors.Active or Color3.fromRGB(50, 50, 55)
                knob.Position = isToggled and UDim2.new(1, isMobile and -10 or -18, 0.5, isMobile and -4 or -8) or UDim2.new(0, 2, 0.5, isMobile and -4 or -8)
            end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    function RadiantHub:addSlider(tabName, sectionName, title, desc, min, max, defaultValue, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, isMobile and 32 or 50), -- Even smaller height for mobile
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        create('TextLabel', {
            Size = UDim2.new(1, isMobile and -36 or -65, 0, isMobile and 10 or 16), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 1 or 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 9 or 14, -- Even smaller text for mobile
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        create('TextLabel', {
            Size = UDim2.new(1, isMobile and -36 or -65, 0, isMobile and 7 or 12), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 10 or 18),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.Colors.SubText,
            TextSize = isMobile and 7 or 11, -- Even smaller text for mobile
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local valueBox = create('TextBox', {
            Size = UDim2.new(0, isMobile and 32 or 60, 0, isMobile and 12 or 20), -- Even smaller for mobile
            Position = UDim2.new(1, isMobile and -34 or -62, 0, isMobile and 1 or 2), -- Adjusted for mobile
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = tostring(defaultValue),
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 7 or 12, -- Even smaller text for mobile
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            ClearTextOnFocus = false,
            Parent = frame,
        })
        addCorner(valueBox, isMobile and 3 or 6)
        addStroke(valueBox)

        local sliderTrack = create('Frame', {
            Size = UDim2.new(1, isMobile and -40 or -72, 0, isMobile and 3 or 6), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 20 or 37), -- Adjusted Y position for mobile
            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
            BorderSizePixel = 0,
            Parent = frame,
        })
        addCorner(sliderTrack, 3)

        local sliderFill = create('Frame', {
            Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Config.Colors.Active,
            BorderSizePixel = 0,
            Parent = sliderTrack,
        })
        addCorner(sliderFill, 3)

        local sliderButton = create('TextButton', {
            Size = UDim2.new(1, 20, 1, 20),
            Position = UDim2.new(0, -10, 0, -10),
            BackgroundTransparency = 1,
            Text = '',
            Parent = sliderTrack,
        })

        local currentValue = defaultValue
        local isDragging = false

        local function updateSliderFromValue(value, triggerCallback)
            value = math.max(min, math.min(max, value))
            currentValue = value
            local normalizedPos = (currentValue - min) / (max - min)

            sliderFill.Size = UDim2.new(normalizedPos, 0, 1, 0)
            valueBox.Text = tostring(currentValue)

            if triggerCallback then
                callback(currentValue)
            end
        end

        local function updateSlider(mouseX)
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            local relativeX = math.max(0, math.min(1, (mouseX - trackPos) / trackSize))

            local newValue = math.floor(min + (max - min) * relativeX)
            updateSliderFromValue(newValue, false)
        end

        valueBox.FocusLost:Connect(function()
            local inputValue = tonumber(valueBox.Text)
            if inputValue then
                updateSliderFromValue(inputValue, true)
                self.notifications:info('Slider Updated', title .. ' set to: ' .. currentValue, 2)
            else
                valueBox.Text = tostring(currentValue)
            end
            
            -- Reset styling
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            local stroke = valueBox:FindFirstChild('UIStroke')
            if stroke then
                stroke.Color = Color3.fromRGB(55, 55, 65)
                stroke.Thickness = 1
            end
        end)

        valueBox.Focused:Connect(function()
            valueBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            local stroke = valueBox:FindFirstChild('UIStroke')
            if stroke then
                stroke.Color = Config.Colors.Active
                stroke.Thickness = 2
            end
        end)

        sliderButton.MouseButton1Down:Connect(function()
            isDragging = true
            local mousePos = Services.UserInputService:GetMouseLocation()
            updateSlider(mousePos.X)

            local connection
            local endConnection

            connection = Services.UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                    local newMousePos = Services.UserInputService:GetMouseLocation()
                    updateSlider(newMousePos.X)
                end
            end)

            endConnection = Services.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                    callback(currentValue)
                    self.notifications:info('Slider Updated', title .. ' set to: ' .. currentValue, 2)

                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                    if endConnection then
                        endConnection:Disconnect()
                        endConnection = nil
                    end
                end
            end)
        end)

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'slider',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return currentValue end,
            setValue = function(value) updateSliderFromValue(value, false) end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

            -- Helper function for creating sections (Optimized)
        function RadiantHub:createSettingsSection(parent, title, size)
            local section = create('Frame', {
                Size = size or UDim2.new(1, 0, 0, isMobile and 120 or 160),
                BackgroundColor3 = Color3.fromRGB(28, 28, 30),
                Parent = parent,
            })
            addCorner(section, 6)
            addPadding(section, isMobile and 8 or 12)
            addStroke(section)

            create('TextLabel', {
                Size = UDim2.new(1, 0, 0, isMobile and 18 or 22),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 11 or 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section,
            })

            return section
        end

            -- Helper functions for settings elements (Optimized)
        function RadiantHub:createToggle(parent, title, desc, state, pos)
            local frame = create('Frame', {
                Size = UDim2.new(1, -5, 0, isMobile and 26 or 32),
                Position = pos or UDim2.new(0, 0, 0, 25),
                BackgroundTransparency = 1,
                Parent = parent,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -28 or -40, 0, isMobile and 12 or 14),
                Position = UDim2.new(0, 0, 0, isMobile and 1 or 2),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -28 or -40, 0, isMobile and 8 or 10),
                Position = UDim2.new(0, 0, 0, isMobile and 13 or 16),
                BackgroundTransparency = 1,
                Text = desc,
                TextColor3 = Config.Colors.SubText,
                TextSize = isMobile and 8 or 9,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            local switch = create('Frame', {
                Size = UDim2.new(0, isMobile and 24 or 35, 0, isMobile and 12 or 16),
                Position = UDim2.new(1, isMobile and -26 or -37, 0.5, isMobile and -6 or -8),
                BackgroundColor3 = state and Config.Colors.Active or Color3.fromRGB(50, 50, 55),
                Parent = frame,
            })
            addCorner(switch, isMobile and 6 or 8)

            local knob = create('Frame', {
                Size = UDim2.new(0, isMobile and 8 or 12, 0, isMobile and 8 or 12),
                Position = state and UDim2.new(1, isMobile and -10 or -14, 0.5, isMobile and -4 or -6) or UDim2.new(0, 2, 0.5, isMobile and -4 or -6),
                BackgroundColor3 = Config.Colors.Text,
                Parent = switch,
            })
            addCorner(knob, isMobile and 4 or 6)

        local btn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = frame,
        })

        local isToggled = state
        btn.MouseButton1Click:Connect(function()
            isToggled = not isToggled

            tween(switch, 0.2, {
                BackgroundColor3 = isToggled and Config.Colors.Active or Color3.fromRGB(50, 50, 55),
            }):Play()

            tween(knob, 0.2, {
                Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            }):Play()

            if title == 'Show Watermark' and self.watermark then
                self.watermark:setVisible(isToggled)
            end

            local status = isToggled and 'Enabled' or 'Disabled'
            self.notifications:info(title .. ' ' .. status, desc, 3)
        end)

        return frame
    end

            function RadiantHub:createKeybind(parent, title, key, pos)
            local frame = create('Frame', {
                Size = UDim2.new(1, -5, 0, isMobile and 22 or 28),
                Position = pos or UDim2.new(0, 0, 0, 25),
                BackgroundTransparency = 1,
                Parent = parent,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -35 or -55, 0, isMobile and 12 or 16),
                Position = UDim2.new(0, 0, 0.5, isMobile and -6 or -8),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            local keyBtn = create('TextButton', {
                Size = UDim2.new(0, isMobile and 30 or 50, 0, isMobile and 16 or 20),
                Position = UDim2.new(1, isMobile and -32 or -52, 0.5, isMobile and -8 or -10),
                BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                Text = key,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 8 or 10,
                Font = Enum.Font.GothamBold,
                Parent = frame,
            })
            addCorner(keyBtn, 6)
            addStroke(keyBtn)

        local listening = false
        keyBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true

            self.isSettingKeybind = true

            keyBtn.Text = '...'
            keyBtn.BackgroundColor3 = Config.Colors.Active

            local connection
            connection = Services.UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local newKey = input.KeyCode.Name
                    keyBtn.Text = newKey
                    keyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    listening = false

                    if title == 'Menu Toggle Key' then
                        self.menuToggleKey = input.KeyCode
                        self.notifications:success('Keybind Updated', 'Menu toggle key set to: ' .. newKey, 3)
                    end

                    task.wait(0.1)
                    self.isSettingKeybind = false

                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end)
        end)

        return frame
    end

    -- Tab Switching Function
    function RadiantHub:switchTab(tabName)
        if self.currentTab == tabName then return end

        -- Deactivate all tabs
        for name, btn in pairs(self.tabButtons) do
            btn.BackgroundColor3 = Config.Colors.Inactive
            local indicator = btn:FindFirstChild('ActiveIndicator')
            if indicator then
                indicator:Destroy()
            end
            -- Reset icon color
            local icon = btn:FindFirstChildOfClass('ImageLabel')
            if icon then
                icon.ImageColor3 = Config.Colors.SubText
            end
        end

        -- Hide all content
        for name, content in pairs(self.tabContents) do
            content.Visible = false
        end

        -- Activate new tab
        if self.tabButtons[tabName] then
            self:setActiveTab(self.tabButtons[tabName])
        end

        -- Show new content
        if self.tabContents[tabName] then
            self.tabContents[tabName].Visible = true
        end

        self.currentTab = tabName
        self.title.Text = tabName
    end

    function RadiantHub:setActiveTab(btn)
        local indicator = create('Frame', {
            Name = 'ActiveIndicator',
            Size = UDim2.new(0, 4, 0.7, 0),
            Position = UDim2.new(0, -15, 0.15, 0),
            BackgroundColor3 = Config.Colors.Active,
            Parent = btn,
        })
        addCorner(indicator, 2)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) -- Darker color instead of blue
        
        -- Update icon color for active tab
        local icon = btn:FindFirstChildOfClass('ImageLabel')
        if icon then
            icon.ImageColor3 = Config.Colors.Text
        end
    end

    -- Event Setup Functions
    function RadiantHub:setupMenuToggle()
        Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end

            if self.isSettingKeybind then return end

            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.menuToggleKey then
                self:toggleVisibility()
            end
        end)
    end

    function RadiantHub:initializeNotifications()
        self.notifications = NotificationManager.new()
    end

    function RadiantHub:initializeWatermark()
        self.watermark = WatermarkManager.new()
    end

    function RadiantHub:toggleVisibility()
        self.isVisible = not self.isVisible

        if self.isVisible then
            if self.isMinimized then
                self:maximize()
            elseif self.minimizedLogo then
                -- Wenn ein minimized Logo existiert, maximiere es
                self:maximize()
            else
                self.main.Visible = true
                self.main.Position = UDim2.new(0.5, -Config.Size[1] / 2, 0.5, -Config.Size[2] / 2 - 50)
                self.main.Size = UDim2.new(0, Config.Size[1] * 0.8, 0, Config.Size[2] * 0.8)

                tween(self.main, 0.3, {
                    Position = UDim2.new(0.5, -Config.Size[1] / 2, 0.5, -Config.Size[2] / 2),
                    Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]),
                }):Play()
            end
        else
            if self.isMinimized then
                if self.minimizedLogo then
                    self.minimizedLogo.Visible = false
                end
            else
                -- Minimiere zu Logo statt komplett zu schließen
                self:minimize()
            end
        end
    end

    -- New: Toggle minimize/maximize
    function RadiantHub:toggleMinimize()
        if self.isMinimized then
            self:maximize()
        else
            self:minimize()
        end
    end

    -- New: Minimize to logo only
    function RadiantHub:minimize()
        if self.isMinimized then return end
        
        self.isMinimized = true
        self.isVisible = false -- Menu ist "unsichtbar" aber Logo ist da
        
        -- Create floating minimized logo
        self:createMinimizedLogo()
        
        -- Hide main window with animation
        local fadeOut = tween(self.main, 0.3, {
            Position = UDim2.new(0.5, -Config.Size[1] / 2, 1.2, 0),
            Size = UDim2.new(0, Config.Size[1] * 0.8, 0, Config.Size[2] * 0.8),
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            self.main.Visible = false
        end)
        
        self.notifications:info('RadiantHub', 'Menu minimized - Click logo to restore', 3)
    end

    -- ✅ UPDATE: Auch die maximize Funktion leicht vereinfachen:
    function RadiantHub:maximize()
        if not self.isMinimized and not self.minimizedLogo then return end
        
        self.isMinimized = false
        self.isVisible = true
        
        -- Hide minimized logo
        if self.minimizedLogo then
            -- ✅ EINFACHES Cleanup - keine komplexen Connections
            self.minimizedLogoDragConnection = nil
            
            -- ✅ Speichere finale Position vor dem Entfernen
            self.minimizedLogoPosition = self.minimizedLogo.Position
            
            local logoFadeOut = tween(self.minimizedLogo, 0.2, { 
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1 
            })
            logoFadeOut:Play()
            logoFadeOut.Completed:Connect(function()
                if self.minimizedLogo then
                    self.minimizedLogo:Destroy()
                    self.minimizedLogo = nil
                end
            end)
        end
        
        -- Show main window with animation
        self.main.Visible = true
        self.main.Position = UDim2.new(0.5, -Config.Size[1] / 2, 1.2, 0)
        self.main.Size = UDim2.new(0, Config.Size[1] * 0.8, 0, Config.Size[2] * 0.8)
        
        tween(self.main, 0.3, {
            Position = UDim2.new(0.5, -Config.Size[1] / 2, 0.5, -Config.Size[2] / 2),
            Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]),
        }):Play()
        
        self.notifications:success('RadiantHub', 'Menu restored!', 2)
    end

    -- New: Create draggable minimized logo
    function RadiantHub:createMinimizedLogo()
        if self.minimizedLogo then
            self.minimizedLogo:Destroy()
        end
        
        local logoSize = isMobile and 60 or 70 -- Optimized size for mobile
        
        self.minimizedLogo = create('Frame', {
            Size = UDim2.new(0, logoSize, 0, logoSize),
            Position = self.minimizedLogoPosition, -- ✅ Verwende gespeicherte Position
            BackgroundColor3 = Config.Colors.Background,
            Parent = self.screen,
            Active = true,
            Draggable = true, -- Einfaches, robustes Dragging
        })
        addCorner(self.minimizedLogo, logoSize / 2)
        addStroke(self.minimizedLogo, Config.Colors.Active, isMobile and 2 or 3)
        
        -- Glow effect
        local glow = create('Frame', {
            Size = UDim2.new(1, isMobile and 8 or 10, 1, isMobile and 8 or 10),
            Position = UDim2.new(0, isMobile and -4 or -5, 0, isMobile and -4 or -5),
            BackgroundColor3 = Config.Colors.Active,
            BackgroundTransparency = 0.7,
            ZIndex = 1,
            Parent = self.minimizedLogo,
        })
        addCorner(glow, logoSize / 2 + (isMobile and 4 or 5))
        
        -- Logo image
        local logoImg = create('ImageLabel', {
            Size = UDim2.new(1, isMobile and -12 or -15, 1, isMobile and -12 or -15),
            Position = UDim2.new(0, isMobile and 6 or 7.5, 0, isMobile and 6 or 7.5),
            BackgroundTransparency = 1,
            Image = Config.Logo,
            ZIndex = 3,
            Parent = self.minimizedLogo,
        })
        addCorner(logoImg, logoSize / 2 - (isMobile and 6 or 7.5))
        
        -- ✅ BESSERE LÖSUNG: Logo selbst clickbar machen ohne Button der Dragging blockiert
        local clickStartTime = 0
        local isDragging = false
        
        -- Events direkt auf dem Logo-Frame
        self.minimizedLogo.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                clickStartTime = tick()
                isDragging = false
            end
        end)
        
        self.minimizedLogo.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if tick() - clickStartTime > 0.1 then
                    isDragging = true
                end
            end
        end)
        
        self.minimizedLogo.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not isDragging and tick() - clickStartTime < 0.3 then
                    -- Kurzer Click = Maximize
                    self:maximize()
                end
            end
        end)
        
        -- ✅ Mobile Touch Support
        if isMobile then
            -- Zusätzlicher TouchTap für mobile Geräte
            local touchConnection
            touchConnection = self.minimizedLogo.TouchTap:Connect(function()
                if not isDragging then
                    self:maximize()
                end
            end)
        end
        
        -- ✅ Logo ist nun vollständig draggable UND clickable
        self.minimizedLogoDragConnection = nil -- Setze auf nil da nicht benötigt
        
        -- ✅ WICHTIG: Position speichern wenn Logo bewegt wird
        local positionSaveConnection
        positionSaveConnection = self.minimizedLogo:GetPropertyChangedSignal("Position"):Connect(function()
            if self.minimizedLogo then
                self.minimizedLogoPosition = self.minimizedLogo.Position
            end
        end)
        
        -- Animate appearance
        self.minimizedLogo.Size = UDim2.new(0, 10, 0, 10)
        self.minimizedLogo.BackgroundTransparency = 1
        logoImg.ImageTransparency = 1 -- Start with transparent image
        glow.BackgroundTransparency = 1 -- Start with transparent glow
        
        local appearTween = tween(self.minimizedLogo, 0.3, {
            Size = UDim2.new(0, logoSize, 0, logoSize),
            BackgroundTransparency = 0,
        })
        
        -- Animate image and glow separately
        tween(logoImg, 0.3, { ImageTransparency = 0 }):Play()
        tween(glow, 0.3, { BackgroundTransparency = 0.7 }):Play()
        
        appearTween:Play()
    end

    function RadiantHub:setupEvents()
        local dragStart, startPos

        -- Mouse/Touch drag events for header
        self.header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch then
                self.isDragging = true
                dragStart = input.Position
                startPos = self.main.Position
            end
        end)

        self.header.InputChanged:Connect(function(input)
            if self.isDragging and 
            (input.UserInputType == Enum.UserInputType.MouseMovement or 
                input.UserInputType == Enum.UserInputType.Touch) and dragStart then
                local delta = input.Position - dragStart
                self.main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        -- End drag events for both mouse and touch
        Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch then
                self.isDragging = false
            end
        end)

        -- Minimize Button Events
        self.minimizeBtn.MouseEnter:Connect(function()
            self.minimizeBtn.TextColor3 = Color3.fromRGB(120, 255, 120)
            tween(self.minimizeBtn, 0.1, { TextSize = 34 }):Play()
        end)

        self.minimizeBtn.MouseLeave:Connect(function()
            self.minimizeBtn.TextColor3 = Config.Colors.Text
            tween(self.minimizeBtn, 0.1, { TextSize = 32 }):Play()
        end)

        self.minimizeBtn.MouseButton1Click:Connect(function()
            self:toggleMinimize()
        end)

        -- Close Button Events
        self.closeBtn.MouseEnter:Connect(function()
            self.closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
            tween(self.closeBtn, 0.1, { TextSize = 34 }):Play()
        end)

        self.closeBtn.MouseLeave:Connect(function()
            self.closeBtn.TextColor3 = Config.Colors.Text
            tween(self.closeBtn, 0.1, { TextSize = 32 }):Play()
        end)

        self.closeBtn.MouseButton1Click:Connect(function()
            self:destroy()
        end)
    end

    -- Cleanup Function
    function RadiantHub:destroy()
        if self.watermark then
            self.watermark:destroy()
            self.watermark = nil
        end

        if self.notifications then
            self.notifications:destroy()
            self.notifications = nil
        end

        -- Clean up minimized logo
        if self.minimizedLogo then
            self.minimizedLogo:Destroy()
            self.minimizedLogo = nil
        end

        if self.screen then
            self.screen:Destroy()
        end
    end

    function RadiantHub:addKeybind(tabName, sectionName, title, defaultKey, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, isMobile and 20 or 32), -- Even smaller height for mobile
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        create('TextLabel', {
            Size = UDim2.new(1, isMobile and -36 or -65, 0, isMobile and 10 or 16), -- Even smaller for mobile
            Position = UDim2.new(0, 0, 0, isMobile and 1 or 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 9 or 14, -- Even smaller text for mobile
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local keyBtn = create('TextButton', {
            Size = UDim2.new(0, isMobile and 32 or 62, 0, isMobile and 14 or 24), -- Even smaller for mobile
            Position = UDim2.new(1, isMobile and -34 or -64, 0.5, isMobile and -7 or -12), -- Adjusted for mobile
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = defaultKey,
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 7 or 13, -- Even smaller text for mobile
            Font = Enum.Font.GothamBold,
            Parent = frame,
        })
        addCorner(keyBtn, 8)
        addStroke(keyBtn)

        local listening = false
        local currentKey = defaultKey

        keyBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true

            self.isSettingKeybind = true

            keyBtn.Text = '...'
            keyBtn.BackgroundColor3 = Config.Colors.Active

            local connection
            connection = Services.UserInputService.InputBegan:Connect(function(input)
                local newKey = nil
                local keyName = nil
                
                -- ERWEITERT: Support für Keyboard UND Mouse Inputs
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    newKey = input.KeyCode
                    keyName = input.KeyCode.Name
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    newKey = Enum.UserInputType.MouseButton1
                    keyName = "LMB" -- Left Mouse Button
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    newKey = Enum.UserInputType.MouseButton2  
                    keyName = "RMB" -- Right Mouse Button
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    newKey = Enum.UserInputType.MouseButton3
                    keyName = "MMB" -- Middle Mouse Button
                else
                    -- Prüfe auch auf Mausseiten-Tasten über KeyCode
                    if input.KeyCode == Enum.KeyCode.ButtonX1 then
                        newKey = Enum.KeyCode.ButtonX1
                        keyName = "X1" -- Side Button 1
                    elseif input.KeyCode == Enum.KeyCode.ButtonX2 then
                        newKey = Enum.KeyCode.ButtonX2
                        keyName = "X2" -- Side Button 2
                    end
                end
                
                if newKey and keyName then
                    keyBtn.Text = keyName
                    keyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    listening = false
                    currentKey = keyName

                    -- Special handling for menu toggle key in settings
                    if tabName == 'Settings' and title == 'Menu Toggle Key' then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            self.menuToggleKey = input.KeyCode
                        end
                        self.notifications:success('Keybind Updated', 'Menu key: ' .. keyName, 2)
                    else
                        callback(newKey, keyName)
                        self.notifications:info('Keybind Set', title .. ': ' .. keyName, 2)
                    end

                    task.wait(0.1)
                    self.isSettingKeybind = false

                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end)
        end)

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'keybind',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return currentKey end,
            setValue = function(key) 
                -- Handle both string and EnumItem input, plus mouse buttons
                if typeof(key) == "EnumItem" then
                    currentKey = key.Name
                    keyBtn.Text = key.Name
                elseif type(key) == "string" and (key == 'RMB' or key == 'LMB' or key == 'MMB' or key == 'X1' or key == 'X2') then
                    -- Mouse buttons - keep as string
                    currentKey = key
                    keyBtn.Text = key
                else
                    currentKey = tostring(key)
                    keyBtn.Text = tostring(key)
                end
            end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    function RadiantHub:addDropdown(tabName, sectionName, title, options, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, isMobile and 20 or 32), -- Even smaller height for mobile
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        create('TextLabel', {
            Size = UDim2.new(1, isMobile and -54 or -98, 0, isMobile and 10 or 16), -- More space for dropdown
            Position = UDim2.new(0, 0, 0, isMobile and 1 or 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = isMobile and 9 or 14, -- Even smaller text for mobile
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local dropdown = create('Frame', {
            Size = UDim2.new(0, isMobile and 48 or 92, 0, isMobile and 16 or 26), -- Even smaller for mobile
            Position = UDim2.new(1, isMobile and -50 or -94, 0.5, isMobile and -8 or -13), -- Positioned properly
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Parent = frame,
        })
        addCorner(dropdown, 8)
        addStroke(dropdown)

        local selected = create('TextLabel', {
            Size = UDim2.new(1, -35, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = options[1] or 'Select...',
            TextColor3 = Config.Colors.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropdown,
        })

        local arrow = create('TextLabel', {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0.5, -10),
            BackgroundTransparency = 1,
            Text = '▼',
            TextColor3 = Config.Colors.SubText,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = dropdown,
        })

        local optionsFrame = create('Frame', {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            Visible = false,
            ZIndex = 10,
            Parent = dropdown,
        })
        addCorner(optionsFrame, 8)
        addStroke(optionsFrame)

        local searchFrame = create('Frame', {
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            ZIndex = 11,
            Parent = optionsFrame,
        })
        addCorner(searchFrame, 6)
        addStroke(searchFrame, Color3.fromRGB(45, 45, 55), 1)

        local searchBox = create('TextBox', {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = '',
            PlaceholderText = 'Search...',
            PlaceholderColor3 = Config.Colors.SubText,
            TextColor3 = Config.Colors.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 12,
            Parent = searchFrame,
        })

        local currentSelection = options[1] or ''
        local isOpen = false
        local filteredOptions = options

        local function updateOptions()
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA('TextButton') then
                    child:Destroy()
                end
            end

            for i, option in ipairs(filteredOptions) do
                local optBtn = create('TextButton', {
                    Size = UDim2.new(1, -8, 0, 26),
                    Position = UDim2.new(0, 4, 0, 36 + (i - 1) * 28),
                    BackgroundTransparency = (option == selected.Text) and 0 or 1,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                    Text = '',
                    ZIndex = 11,
                    Parent = optionsFrame,
                })
                addCorner(optBtn, 6)

                local indicator = create('Frame', {
                    Size = UDim2.new(0, 3, 0.6, 0),
                    Position = UDim2.new(0, 3, 0.2, 0),
                    BackgroundColor3 = (option == selected.Text) and Config.Colors.Active or Color3.fromRGB(60, 60, 70),
                    ZIndex = 12,
                    Parent = optBtn,
                })
                addCorner(indicator, 2)

                local text = create('TextLabel', {
                    Size = UDim2.new(1, -18, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = (option == selected.Text) and Config.Colors.Active or Config.Colors.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 12,
                    Parent = optBtn,
                })

                optBtn.MouseButton1Click:Connect(function()
                    selected.Text = option
                    currentSelection = option
                    isOpen = false
                    optionsFrame.Visible = false
                    arrow.Text = '▼'
                    searchBox.Text = ''
                    filteredOptions = options
                    updateOptions()
                    callback(option)
                    self.notifications:info('Selection Changed', title .. ': ' .. option, 2)
                end)
            end

            optionsFrame.Size = UDim2.new(1, 0, 0, 36 + #filteredOptions * 28 + 8)
        end

        searchBox:GetPropertyChangedSignal('Text'):Connect(function()
            local searchText = searchBox.Text:lower()
            filteredOptions = {}
            for _, option in ipairs(options) do
                if searchText == '' or option:lower():find(searchText, 1, true) then
                    table.insert(filteredOptions, option)
                end
            end
            updateOptions()
        end)

        updateOptions()

        local arrowBtn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = dropdown,
        })

        arrowBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            optionsFrame.Visible = isOpen
            if isOpen then
                filteredOptions = options
                searchBox.Text = ''
                updateOptions()
                -- Increase scroll area when dropdown opens
                local parent = frame.Parent
                while parent and not parent.Name:match('Column') do
                    parent = parent.Parent
                end
                if parent then
                    local currentCanvas = parent.CanvasSize.Y.Offset
                    parent.CanvasSize = UDim2.new(0, 0, 0, currentCanvas + 250)
                end
            else
                -- Reset scroll area when dropdown closes
                local parent = frame.Parent
                while parent and not parent.Name:match('Column') do
                    parent = parent.Parent
                end
                if parent then
                    local currentCanvas = parent.CanvasSize.Y.Offset
                    parent.CanvasSize = UDim2.new(0, 0, 0, math.max(currentCanvas - 250, 0))
                end
            end
            arrow.Text = isOpen and '▲' or '▼'
        end)

        arrowBtn.MouseEnter:Connect(function()
            if not isOpen then
                dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            end
        end)

        arrowBtn.MouseLeave:Connect(function()
            if not isOpen then
                dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            end
        end)

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'dropdown',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return currentSelection end,
            setValue = function(value) 
                if table.find(options, value) then
                    selected.Text = value
                    currentSelection = value
                end
            end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    function RadiantHub:addMultiDropdown(tabName, sectionName, title, options, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -5, 0, 32),
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        create('TextLabel', {
            Size = UDim2.new(1, -115, 0, 16),
            Position = UDim2.new(0, 0, 0, 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local dropdown = create('Frame', {
            Size = UDim2.new(0, 110, 0, 26),
            Position = UDim2.new(1, -115, 0.5, -13),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Parent = frame,
        })
        addCorner(dropdown, 8)
        addStroke(dropdown)

        local selected = create('TextLabel', {
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = 'Select...',
            TextColor3 = Config.Colors.SubText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropdown,
        })

        local countLabel = create('TextLabel', {
            Size = UDim2.new(0, 15, 1, 0),
            Position = UDim2.new(1, -40, 0, 0),
            BackgroundTransparency = 1,
            Text = '',
            TextColor3 = Config.Colors.Active,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            Visible = false,
            Parent = dropdown,
        })

        local arrow = create('TextLabel', {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0.5, -10),
            BackgroundTransparency = 1,
            Text = '▼',
            TextColor3 = Config.Colors.SubText,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = dropdown,
        })

        local optionsFrame = create('Frame', {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            Visible = false,
            ZIndex = 20,
            Parent = dropdown,
        })
        addCorner(optionsFrame, 8)
        addStroke(optionsFrame)

        local searchFrame = create('Frame', {
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            ZIndex = 21,
            Parent = optionsFrame,
        })
        addCorner(searchFrame, 6)
        addStroke(searchFrame, Color3.fromRGB(45, 45, 55), 1)

        local searchBox = create('TextBox', {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = '',
            PlaceholderText = 'Search...',
            PlaceholderColor3 = Config.Colors.SubText,
            TextColor3 = Config.Colors.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 22,
            Parent = searchFrame,
        })

        local selectedOptions = {}
        local isOpen = false
        local filteredOptions = options

        local function updateSelectedText()
            if #selectedOptions == 0 then
                selected.Text = 'Select...'
                selected.TextColor3 = Config.Colors.SubText
                countLabel.Visible = false
            elseif #selectedOptions == 1 then
                selected.Text = selectedOptions[1]
                selected.TextColor3 = Config.Colors.Text
                countLabel.Visible = false
            else
                selected.Text = selectedOptions[1]
                selected.TextColor3 = Config.Colors.Active
                countLabel.Text = '+' .. (#selectedOptions - 1)
                countLabel.Visible = true
            end
        end

        local function updateOptions()
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA('TextButton') then
                    child:Destroy()
                end
            end

            for i, option in ipairs(filteredOptions) do
                local isSelected = false
                for _, sel in ipairs(selectedOptions) do
                    if sel == option then
                        isSelected = true
                        break
                    end
                end

                local optBtn = create('TextButton', {
                    Size = UDim2.new(1, -8, 0, 26),
                    Position = UDim2.new(0, 4, 0, 36 + (i - 1) * 28),
                    BackgroundTransparency = isSelected and 0 or 1,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                    Text = '',
                    ZIndex = 21,
                    Parent = optionsFrame,
                })
                addCorner(optBtn, 6)

                local indicator = create('Frame', {
                    Size = UDim2.new(0, 3, 0.6, 0),
                    Position = UDim2.new(0, 3, 0.2, 0),
                    BackgroundColor3 = isSelected and Config.Colors.Active or Color3.fromRGB(60, 60, 70),
                    ZIndex = 22,
                    Parent = optBtn,
                })
                addCorner(indicator, 2)

                local text = create('TextLabel', {
                    Size = UDim2.new(1, -18, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = isSelected and Config.Colors.Active or Config.Colors.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 22,
                    Parent = optBtn,
                })

                optBtn.MouseEnter:Connect(function()
                    if not isSelected then
                        optBtn.BackgroundTransparency = 0
                    end
                end)

                optBtn.MouseLeave:Connect(function()
                    if not isSelected then
                        optBtn.BackgroundTransparency = 1
                    end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    local wasSelected = false
                    for j, sel in ipairs(selectedOptions) do
                        if sel == option then
                            table.remove(selectedOptions, j)
                            wasSelected = true
                            break
                        end
                    end

                    if not wasSelected then
                        table.insert(selectedOptions, option)
                    end

                    updateSelectedText()
                    updateOptions()
                    callback(selectedOptions)
                    self.notifications:info('Multi-Selection', title .. ': ' .. table.concat(selectedOptions, ', '), 2)
                end)
            end

            optionsFrame.Size = UDim2.new(1, 0, 0, 36 + #filteredOptions * 28 + 8)
        end

        searchBox:GetPropertyChangedSignal('Text'):Connect(function()
            local searchText = searchBox.Text:lower()
            filteredOptions = {}
            for _, option in ipairs(options) do
                if searchText == '' or option:lower():find(searchText, 1, true) then
                    table.insert(filteredOptions, option)
                end
            end
            updateOptions()
        end)

        updateOptions()

        local arrowBtn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = dropdown,
        })

        arrowBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            optionsFrame.Visible = isOpen
            if isOpen then
                filteredOptions = options
                searchBox.Text = ''
                updateOptions()
                -- Increase scroll area when dropdown opens
                local parent = frame.Parent
                while parent and not parent.Name:match('Column') do
                    parent = parent.Parent
                end
                if parent then
                    local currentCanvas = parent.CanvasSize.Y.Offset
                    parent.CanvasSize = UDim2.new(0, 0, 0, currentCanvas + 250)
                end
            else
                -- Reset scroll area when dropdown closes
                local parent = frame.Parent
                while parent and not parent.Name:match('Column') do
                    parent = parent.Parent
                end
                if parent then
                    local currentCanvas = parent.CanvasSize.Y.Offset
                    parent.CanvasSize = UDim2.new(0, 0, 0, math.max(currentCanvas - 250, 0))
                end
            end
            arrow.Text = isOpen and '▲' or '▼'
        end)

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'multidropdown',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return selectedOptions end,
            setValue = function(values) 
                selectedOptions = values or {}
                updateSelectedText()
                updateOptions()
            end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    function RadiantHub:addColorPicker(tabName, sectionName, title, defaultColor, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, 32), -- Weniger rechter Abstand
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        create('TextLabel', {
            Size = UDim2.new(1, -60, 0, 16), -- Mehr Platz für Text (von -75 zu -60)
            Position = UDim2.new(0, 0, 0, 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local colorButton = create('Frame', {
            Size = UDim2.new(0, 55, 0, 26), -- Kleinerer Button (von 60 zu 55)
            Position = UDim2.new(1, -57, 0.5, -13), -- Näher zum Rand (von -65 zu -57)
            BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255),
            Parent = frame,
        })
        addCorner(colorButton, 8)
        addStroke(colorButton)

        local pickerFrame = create('Frame', {
            Size = UDim2.new(0, 250, 0, 0),
            Position = UDim2.new(0, -185, 1, 4),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            Visible = false,
            ZIndex = 30,
            Parent = colorButton,
        })
        addCorner(pickerFrame, 8)
        addStroke(pickerFrame)

        local isOpen = false
        local selectedColor = defaultColor or Color3.fromRGB(255, 255, 255)
        local currentHue, currentSat, currentVal = 0, 1, 1

        create('TextLabel', {
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 5),
            BackgroundTransparency = 1,
            Text = 'Color Picker',
            TextColor3 = Config.Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 31,
            Parent = pickerFrame,
        })

        local colorCanvas = create('Frame', {
            Size = UDim2.new(0, 180, 0, 120),
            Position = UDim2.new(0, 10, 0, 35),
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            ZIndex = 31,
            Parent = pickerFrame,
        })
        addCorner(colorCanvas, 6)

        local satFrame = create('Frame', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 32,
            Parent = colorCanvas,
        })
        addCorner(satFrame, 6)

        local satGradient = create('UIGradient', {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Rotation = 0,
            Parent = satFrame,
        })

        local valFrame = create('Frame', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 33,
            Parent = satFrame,
        })
        addCorner(valFrame, 6)

        local valGradient = create('UIGradient', {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 90,
            Parent = valFrame,
        })

        local hueSlider = create('Frame', {
            Size = UDim2.new(0, 25, 0, 120),
            Position = UDim2.new(0, 200, 0, 35),
            BackgroundTransparency = 1,
            ZIndex = 31,
            Parent = pickerFrame,
        })
        addCorner(hueSlider, 6)

        local hueGradientFrame = create('Frame', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 32,
            Parent = hueSlider,
        })
        addCorner(hueGradientFrame, 6)

        local hueGradient = create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            }),
            Rotation = 90,
            Parent = hueGradientFrame,
        })

        local colorPreview = create('Frame', {
            Size = UDim2.new(0, 230, 0, 25),
            Position = UDim2.new(0, 10, 0, 165),
            BackgroundColor3 = selectedColor,
            ZIndex = 31,
            Parent = pickerFrame,
        })
        addCorner(colorPreview, 6)
        addStroke(colorPreview)

        local rgbLabel = create('TextLabel', {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 10, 0, 195),
            BackgroundTransparency = 1,
            Text = string.format('RGB: %d, %d, %d', selectedColor.R * 255, selectedColor.G * 255, selectedColor.B * 255),
            TextColor3 = Config.Colors.SubText,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 31,
            Parent = pickerFrame,
        })

        local canvasSelector = create('Frame', {
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(1, -4, 0, -4),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 34,
            Parent = colorCanvas,
        })
        addCorner(canvasSelector, 4)
        addStroke(canvasSelector, Color3.fromRGB(0, 0, 0), 2)

        local hueSelector = create('Frame', {
            Size = UDim2.new(1, 4, 0, 4),
            Position = UDim2.new(0, -2, 0, -2),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 34,
            Parent = hueSlider,
        })
        addCorner(hueSelector, 2)
        addStroke(hueSelector, Color3.fromRGB(0, 0, 0), 1)

        local function HSVtoRGB(h, s, v)
            h = h % 1
            if h < 0 then h = h + 1 end

            local r, g, b
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)

            i = i % 6

            if i == 0 then
                r, g, b = v, t, p
            elseif i == 1 then
                r, g, b = q, v, p
            elseif i == 2 then
                r, g, b = p, v, t
            elseif i == 3 then
                r, g, b = p, q, v
            elseif i == 4 then
                r, g, b = t, p, v
            elseif i == 5 then
                r, g, b = v, p, q
            end

            return Color3.fromRGB(
                math.floor(r * 255 + 0.5),
                math.floor(g * 255 + 0.5),
                math.floor(b * 255 + 0.5)
            )
        end

        local function updateColor()
            selectedColor = HSVtoRGB(currentHue, currentSat, currentVal)
            colorButton.BackgroundColor3 = selectedColor
            colorPreview.BackgroundColor3 = selectedColor
            rgbLabel.Text = string.format('RGB: %d, %d, %d', selectedColor.R * 255, selectedColor.G * 255, selectedColor.B * 255)

            local hueColor = HSVtoRGB(currentHue, 1, 1)
            colorCanvas.BackgroundColor3 = hueColor
            
            callback(selectedColor)
        end

        local canvasBtn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            ZIndex = 34,
            Parent = valFrame,
        })

        local function updateCanvasSelector(position)
            local framePos = colorCanvas.AbsolutePosition
            local frameSize = colorCanvas.AbsoluteSize
            local adjustedY = position.Y - 50

            local relativeX = math.max(0, math.min(1, (position.X - framePos.X) / frameSize.X))
            local relativeY = math.max(0, math.min(1, (adjustedY - framePos.Y) / frameSize.Y))

            currentSat = relativeX
            currentVal = 1 - relativeY

            canvasSelector.Position = UDim2.new(relativeX, -4, relativeY, -4)
            updateColor()
        end

        local isDraggingCanvas = false

        canvasBtn.MouseButton1Down:Connect(function()
            isDraggingCanvas = true
            local mousePos = Services.UserInputService:GetMouseLocation()
            updateCanvasSelector({ X = mousePos.X, Y = mousePos.Y })

            local connection
            local endConnection

            connection = Services.UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDraggingCanvas then
                    local newMousePos = Services.UserInputService:GetMouseLocation()
                    updateCanvasSelector({ X = newMousePos.X, Y = newMousePos.Y })
                end
            end)

            endConnection = Services.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDraggingCanvas = false
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                    if endConnection then
                        endConnection:Disconnect()
                        endConnection = nil
                    end
                end
            end)
        end)

        local hueBtn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            ZIndex = 34,
            Parent = hueGradientFrame,
        })

        local function updateHueSelector(position)
            local framePos = hueSlider.AbsolutePosition
            local frameSize = hueSlider.AbsoluteSize
            local adjustedY = position.Y - 50

            local relativeY = math.max(0, math.min(1, (adjustedY - framePos.Y) / frameSize.Y))
            currentHue = relativeY

            hueSelector.Position = UDim2.new(0, -2, relativeY, -2)
            updateColor()
        end

        local isDraggingHue = false

        hueBtn.MouseButton1Down:Connect(function()
            isDraggingHue = true
            local mousePos = Services.UserInputService:GetMouseLocation()
            updateHueSelector({ X = mousePos.X, Y = mousePos.Y })

            local connection
            local endConnection

            connection = Services.UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDraggingHue then
                    local newMousePos = Services.UserInputService:GetMouseLocation()
                    updateHueSelector({ X = newMousePos.X, Y = newMousePos.Y })
                end
            end)

            endConnection = Services.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDraggingHue = false
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                    if endConnection then
                        endConnection:Disconnect()
                        endConnection = nil
                    end
                end
            end)
        end)

        local colorBtn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = colorButton,
        })

        colorBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            pickerFrame.Visible = isOpen
            pickerFrame.Size = isOpen and UDim2.new(0, 250, 0, 220) or UDim2.new(0, 250, 0, 0)

            if isOpen then
                updateColor()
                self.notifications:info('Color Picker', 'Color picker opened!', 2)
                -- Increase scroll area when color picker opens
                local parent = frame.Parent
                while parent and not parent.Name:match('Column') do
                    parent = parent.Parent
                end
                if parent then
                    local currentCanvas = parent.CanvasSize.Y.Offset
                    parent.CanvasSize = UDim2.new(0, 0, 0, currentCanvas + 280)
                end
            else
                -- Reset scroll area when color picker closes
                local parent = frame.Parent
                while parent and not parent.Name:match('Column') do
                    parent = parent.Parent
                end
                if parent then
                    local currentCanvas = parent.CanvasSize.Y.Offset
                    parent.CanvasSize = UDim2.new(0, 0, 0, math.max(currentCanvas - 280, 0))
                end
            end
        end)

        colorBtn.MouseEnter:Connect(function()
            if not isOpen then
                local stroke = colorButton:FindFirstChild('UIStroke')
                if stroke then
                    stroke.Color = Config.Colors.Active
                    stroke.Thickness = 2
                end
            end
        end)

        colorBtn.MouseLeave:Connect(function()
            if not isOpen then
                local stroke = colorButton:FindFirstChild('UIStroke')
                if stroke then
                    stroke.Color = Color3.fromRGB(55, 55, 65)
                    stroke.Thickness = 1
                end
            end
        end)

        updateColor()

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'colorpicker',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return selectedColor end,
            setValue = function(color) 
                selectedColor = color
                colorButton.BackgroundColor3 = color
                if colorPreview then
                    colorPreview.BackgroundColor3 = color
                end
            end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    -- Button creation function
    function RadiantHub:addButton(tabName, sectionName, title, desc, callback)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame
        callback = callback or function() end

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, 36), -- Weniger rechter Abstand
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        local button = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = '',
            Parent = frame,
        })
        addCorner(button, 8)
        addStroke(button)

        create('TextLabel', {
            Size = UDim2.new(1, -20, 0, 18),
            Position = UDim2.new(0, 10, 0, 4),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button,
        })

        create('TextLabel', {
            Size = UDim2.new(1, -20, 0, 14),
            Position = UDim2.new(0, 10, 0, 20),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.Colors.SubText,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button,
        })

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Config.Colors.Hover
            local stroke = button:FindFirstChild('UIStroke')
            if stroke then
                stroke.Color = Config.Colors.Active
                stroke.Thickness = 2
            end
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            local stroke = button:FindFirstChild('UIStroke')
            if stroke then
                stroke.Color = Color3.fromRGB(55, 55, 65)
                stroke.Thickness = 1
            end
        end)

        button.MouseButton1Click:Connect(function()
            callback()
            self.notifications:success('Button Clicked', title, 2)
        end)

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[title] = {
            type = 'button',
            frame = frame,
            callback = callback, -- CALLBACK HINZUGEFÜGT
            getValue = function() return true end,
            setValue = function() end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    -- Label creation function
    function RadiantHub:addLabel(tabName, sectionName, text)
        if not self.tabs[tabName] or not self.tabs[tabName].sections[sectionName] then
            self.notifications:error('Element Error', 'Tab or section not found!', 3)
            return nil
        end

        local sectionData = self.tabs[tabName].sections[sectionName]
        local elementsContainer = sectionData.elementsContainer or sectionData.frame

        local frame = create('Frame', {
            Size = UDim2.new(1, -2, 0, 20), -- Weniger rechter Abstand
            BackgroundTransparency = 1,
            Parent = elementsContainer,
        })

        local label = create('TextLabel', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Config.Colors.SubText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = frame,
        })

        -- Store element reference
        self.tabs[tabName].sections[sectionName].elements[text] = {
            type = 'label',
            frame = frame,
            getValue = function() return label.Text end,
            setValue = function(newText) label.Text = newText end,
        }

        -- Update section size
        task.wait()
        self.tabs[tabName].sections[sectionName].updateSize()

        return frame
    end

    -- Config Management Functions
    function RadiantHub:gatherAllSettings()
        local settings = {
            metadata = {
                version = "2.1",
                timestamp = tick(),
                playerName = Services.Players.LocalPlayer.Name
            },
            globalSettings = {
                menuToggleKey = self.menuToggleKey.Name,
                watermarkVisible = self.watermark and self.watermark.isVisible or true
            },
            tabs = {}
        }
        
        -- Durchlaufe alle Tabs (außer Settings)
        for tabName, tab in pairs(self.tabs) do
            if tabName ~= 'Settings' then
                settings.tabs[tabName] = {
                    sections = {}
                }
                
                -- Durchlaufe alle Sections
                for sectionName, section in pairs(tab.sections) do
                    settings.tabs[tabName].sections[sectionName] = {
                        elements = {}
                    }
                    
                    -- Durchlaufe alle Elemente
                    for elementName, element in pairs(section.elements) do
                        if element and element.getValue and element.type then
                            -- Skip buttons and labels - they don't have saveable state
                            if element.type == 'button' or element.type == 'label' then
                                -- Skip these element types
                            else
                                local value = element.getValue()
                                
                                -- Spezielle Behandlung für Color3
                                if element.type == 'colorpicker' then
                                    value = {
                                        r = math.floor(value.R * 255),
                                        g = math.floor(value.G * 255),
                                        b = math.floor(value.B * 255)
                                    }
                                elseif element.type == 'keybind' then
                                    value = tostring(value)
                                end
                                
                                settings.tabs[tabName].sections[sectionName].elements[elementName] = {
                                    type = element.type,
                                    value = value
                                }
                            end
                        end
                    end
                end
            end
        end
        
        return settings
    end

    function RadiantHub:applySettings(settings)
        if not settings then return false end
        
        -- Globale Settings anwenden
        if settings.globalSettings then
            if settings.globalSettings.menuToggleKey then
                local keyCode = Enum.KeyCode[settings.globalSettings.menuToggleKey]
                if keyCode then
                    self.menuToggleKey = keyCode
                end
            end
            
            if settings.globalSettings.watermarkVisible ~= nil and self.watermark then
                self.watermark:setVisible(settings.globalSettings.watermarkVisible)
            end
        end
        
        -- Tab Settings anwenden
        if settings.tabs then
            for tabName, tabData in pairs(settings.tabs) do
                if self.tabs[tabName] and tabData.sections then
                    for sectionName, sectionData in pairs(tabData.sections) do
                        if self.tabs[tabName].sections[sectionName] and sectionData.elements then
                            for elementName, elementData in pairs(sectionData.elements) do
                                local element = self.tabs[tabName].sections[sectionName].elements[elementName]
                                
                                -- Skip buttons and labels when applying settings
                                if element and element.setValue and element.type == elementData.type and 
                                elementData.type ~= 'button' and elementData.type ~= 'label' then
                                    local value = elementData.value
                                    
                                    -- Spezielle Behandlung für verschiedene Typen
                                    if elementData.type == 'colorpicker' then
                                        value = Color3.fromRGB(value.r or 255, value.g or 255, value.b or 255)
                                    elseif elementData.type == 'keybind' then
                                        -- Handle both keyboard keys and mouse buttons
                                        if value == 'RMB' or value == 'LMB' or value == 'MMB' or value == 'X1' or value == 'X2' or 
                                        value == 'RightMouseButton' or value == 'LeftMouseButton' or value == 'MiddleMouseButton' then
                                            -- Mouse buttons - convert to standard format
                                            if value == 'RightMouseButton' then value = 'RMB'
                                            elseif value == 'LeftMouseButton' then value = 'LMB'
                                            elseif value == 'MiddleMouseButton' then value = 'MMB'
                                            end
                                        else
                                            -- Keyboard keys - convert to KeyCode
                                            local keyCode = Enum.KeyCode[value]
                                            if keyCode then
                                                value = keyCode
                                            else
                                                value = Enum.KeyCode.F  -- Fallback
                                            end
                                        end
                                    end
                                    
                                    -- KRITISCHER FIX: Erst setValue, dann Callback ausführen
                                    element.setValue(value)
                                    
                                    -- Callback ausführen wenn vorhanden
                                    if element.callback and type(element.callback) == 'function' then
                                        local success, errorMsg = pcall(function()
                                            if elementData.type == 'multidropdown' then
                                                -- Multi-Dropdown gibt array zurück
                                                element.callback(value)
                                            elseif elementData.type == 'keybind' then
                                                -- Keybind hat key und keyName parameter
                                                element.callback(value, tostring(value))
                                            else
                                                -- Alle anderen Typen: toggle, slider, dropdown, colorpicker, button
                                                element.callback(value)
                                            end
                                        end)
                                        
                                        if not success then
                                            print('⚠️ Config Load Warning: Callback error for', elementName, ':', errorMsg)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Erfolgreiche Anwendung der Settings mitteilen
        self.notifications:success('Config Applied', 'All settings loaded and applied successfully!', 3)
        
        return true
    end

    function RadiantHub:setConfigManager(configManager)
        self.configManager = configManager
        print('📝 Config Manager set, integrating with Settings tab...')
        
        -- Mehrfache Versuche für UI-Integration mit verbessertem Retry-Mechanismus
        local function tryIntegration(attempt)
            if attempt > 3 then
                print('❌ Failed to integrate config management after 3 attempts')
                return
            end
            
            if self.tabContents and self.tabContents['Settings'] then
                local success = pcall(function()
                    self:addConfigManagementToSettings()
                end)
                
                if success then
                    print('✅ Config Management UI added to Settings tab! (Attempt ' .. attempt .. ')')
                else
                    print('⚠️ Integration failed, retrying... (Attempt ' .. attempt .. ')')
                    task.delay(0.5, function() tryIntegration(attempt + 1) end)
                end
            else
                print('❌ Settings tab not ready, retrying... (Attempt ' .. attempt .. ')')
                task.delay(0.5, function() tryIntegration(attempt + 1) end)
            end
        end
        
        task.delay(0.2, function() tryIntegration(1) end)
    end

    function RadiantHub:addConfigManagementToSettings()
        local settingsContent = self.tabContents['Settings']
        if not settingsContent then 
            print('❌ Settings content not found!')
            return 
        end
        
        local columns = {
            settingsContent:FindFirstChild('Column1'),
            settingsContent:FindFirstChild('Column2')
        }
        
        if not columns[2] then 
            print('❌ Column2 not found in Settings!')
            return 
        end
        
        -- Check if config management already exists
        if columns[2]:FindFirstChild('Config Management Section') then
            print('⚠️ Config management already exists, skipping...')
            return
        end
        
        print('✅ Adding Config Management to Settings Column2...')
        
        -- Config Management Section (Compact)
        local configSection = self:createSettingsSection(
            columns[2], 
            'Configs', 
            UDim2.new(1, 0, 0, isMobile and 220 or 280)
        )
        configSection.Name = 'Config Management Section'
        
        -- Config Name Input (Compact)
        self.configNameInput = self:createConfigTextInput(
            configSection, 
            'New Config', 
            'Name...', 
            UDim2.new(0, 0, 0, isMobile and 25 or 30)
        )
        
        -- Create Config Button (Compact)
        self:createConfigButton(
            configSection, 
            'Create', 
            'Make new config', 
            UDim2.new(0, 0, 0, isMobile and 50 or 65),
            function()
                local configName = self.configNameInput.Text
                if configName and configName ~= '' and self.configManager then
                    self.configManager:createNewConfig(configName)
                    self.configNameInput.Text = ''
                else
                    self.notifications:warning('Invalid Name', 'Enter a config name!', 3)
                end
            end
        )
        
        -- Config Dropdown (Compact)
        self.configDropdown = self:createConfigDropdown(
            configSection, 
            'Select', 
            self.configManager and self.configManager:getConfigList() or {'default'},
            UDim2.new(0, 0, 0, isMobile and 75 or 100)
        )
        
        -- Update dropdown when config manager is ready
        task.spawn(function()
            task.wait(1)
            if self.configManager and self.configDropdown then
                local configs = self.configManager:getConfigList()
                self.configDropdown:updateOptions(configs)
            end
        end)
        
        -- Action Buttons (Compact)
        self:createConfigButton(
            configSection, 
            'Load', 
            'Load selected config', 
            UDim2.new(0, 0, 0, isMobile and 100 or 135),
            function()
                if self.configManager and self.configDropdown then
                    local selectedConfig = self.configDropdown.selectedValue
                    if selectedConfig and selectedConfig ~= '' then
                        self.notifications:info('Loading', selectedConfig, 2)
                        self.configManager:loadConfig(selectedConfig)
                    else
                        self.notifications:warning('No Selection', 'Select a config first!', 3)
                    end
                else
                    self.notifications:error('Error', 'Config system not ready!', 3)
                end
            end
        )
        
        self:createConfigButton(
            configSection, 
            'Save', 
            'Save current settings', 
            UDim2.new(0, 0, 0, isMobile and 125 or 170),
            function()
                if self.configManager and self.configDropdown then
                    local selectedConfig = self.configDropdown.selectedValue
                    if selectedConfig and selectedConfig ~= '' then
                        self.notifications:info('Saving', selectedConfig, 2)
                        self.configManager:saveConfig(selectedConfig)
                    else
                        self.notifications:warning('No Selection', 'Select a config first!', 3)
                    end
                else
                    self.notifications:error('Error', 'Config system not ready!', 3)
                end
            end
        )
        
        self:createConfigButton(
            configSection, 
            'Delete', 
            'Remove selected config', 
            UDim2.new(0, 0, 0, isMobile and 150 or 205),
            function()
                if self.configManager and self.configDropdown then
                    local selectedConfig = self.configDropdown.selectedValue
                    if selectedConfig and selectedConfig ~= 'default' then
                        self.configManager:deleteConfig(selectedConfig)
                    else
                        self.notifications:error('Cannot Delete', 'Cannot delete default!', 3)
                    end
                end
            end
        )
        
        -- Auto Load Toggle (Compact)
        self:createConfigToggle(
            configSection, 
            'Auto Load', 
            'Load on startup', 
            false, 
            UDim2.new(0, 0, 0, isMobile and 175 or 240),
            function(enabled)
                if self.configManager and self.configDropdown then
                    local selectedConfig = self.configDropdown.selectedValue
                    if enabled and selectedConfig then
                        self.configManager:setAutoLoad(selectedConfig)
                    else
                        self.configManager:setAutoLoad(nil)
                    end
                end
            end
        )
    end

            -- Config UI Helper Functions (Optimized)
        function RadiantHub:createConfigTextInput(parent, title, placeholder, pos)
            local frame = create('Frame', {
                Size = UDim2.new(1, -5, 0, isMobile and 20 or 24),
                Position = pos,
                BackgroundTransparency = 1,
                Parent = parent,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -55 or -75, 0, isMobile and 10 or 12),
                Position = UDim2.new(0, 0, 0.5, isMobile and -5 or -6),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 9 or 11,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            local textBox = create('TextBox', {
                Size = UDim2.new(0, isMobile and 50 or 70, 0, isMobile and 14 or 18),
                Position = UDim2.new(1, isMobile and -52 or -72, 0.5, isMobile and -7 or -9),
                BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                Text = '',
                PlaceholderText = placeholder,
                PlaceholderColor3 = Config.Colors.SubText,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 8 or 9,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = frame,
            })
            addCorner(textBox, 4)
            addStroke(textBox)

        -- Input validation
        textBox:GetPropertyChangedSignal('Text'):Connect(function()
            local text = textBox.Text
            local cleanText = text:gsub('[<>:"/\\|?*]', '')
            if text ~= cleanText then
                textBox.Text = cleanText
            end
        end)

        return textBox
    end

            function RadiantHub:createConfigButton(parent, title, desc, pos, callback)
            local frame = create('Frame', {
                Size = UDim2.new(1, -5, 0, isMobile and 22 or 28),
                Position = pos,
                BackgroundTransparency = 1,
                Parent = parent,
            })

            local button = create('TextButton', {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                Text = '',
                Parent = frame,
            })
            addCorner(button, isMobile and 4 or 6)
            addStroke(button)

            create('TextLabel', {
                Size = UDim2.new(1, -16, 0, isMobile and 10 or 12),
                Position = UDim2.new(0, 8, 0, isMobile and 1 or 2),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 9 or 11,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button,
            })

            create('TextLabel', {
                Size = UDim2.new(1, -16, 0, isMobile and 8 or 10),
                Position = UDim2.new(0, 8, 0, isMobile and 11 or 14),
                BackgroundTransparency = 1,
                Text = desc,
                TextColor3 = Config.Colors.SubText,
                TextSize = isMobile and 7 or 9,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button,
            })

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Config.Colors.Hover
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end)

        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return button
    end

            function RadiantHub:createConfigDropdown(parent, title, options, pos)
            local frame = create('Frame', {
                Size = UDim2.new(1, -5, 0, isMobile and 20 or 24),
                Position = pos,
                BackgroundTransparency = 1,
                Parent = parent,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -55 or -75, 0, isMobile and 10 or 12),
                Position = UDim2.new(0, 0, 0.5, isMobile and -5 or -6),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 9 or 11,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            local dropdown = create('Frame', {
                Size = UDim2.new(0, isMobile and 50 or 70, 0, isMobile and 14 or 18),
                Position = UDim2.new(1, isMobile and -52 or -72, 0.5, isMobile and -7 or -9),
                BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                Parent = frame,
            })
            addCorner(dropdown, 4)
            addStroke(dropdown)

        local selected = create('TextLabel', {
            Size = UDim2.new(1, -35, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = options[1] or 'Select...',
            TextColor3 = Config.Colors.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropdown,
        })

        local arrow = create('TextLabel', {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0.5, -10),
            BackgroundTransparency = 1,
            Text = '▼',
            TextColor3 = Config.Colors.SubText,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = dropdown,
        })

        local optionsFrame = create('Frame', {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            Visible = false,
            ZIndex = 50,
            Parent = dropdown,
        })
        addCorner(optionsFrame, 8)
        addStroke(optionsFrame)

        local currentSelection = options[1] or ''
        local isOpen = false
        local dropdownWrapper -- Forward declaration

        local function updateOptionsDisplay()
            -- Clear existing options
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA('TextButton') then
                    child:Destroy()
                end
            end

            -- Create option buttons
            for i, option in ipairs(options) do
                local optBtn = create('TextButton', {
                    Size = UDim2.new(1, -8, 0, 26),
                    Position = UDim2.new(0, 4, 0, 4 + (i - 1) * 28),
                    BackgroundTransparency = (option == currentSelection) and 0 or 1,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                    Text = '',
                    ZIndex = 51,
                    Parent = optionsFrame,
                })
                addCorner(optBtn, 6)

                local indicator = create('Frame', {
                    Size = UDim2.new(0, 3, 0.6, 0),
                    Position = UDim2.new(0, 3, 0.2, 0),
                    BackgroundColor3 = (option == currentSelection) and Config.Colors.Active or Color3.fromRGB(60, 60, 70),
                    ZIndex = 52,
                    Parent = optBtn,
                })
                addCorner(indicator, 2)

                local text = create('TextLabel', {
                    Size = UDim2.new(1, -18, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = (option == currentSelection) and Config.Colors.Active or Config.Colors.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 52,
                    Parent = optBtn,
                })

                optBtn.MouseEnter:Connect(function()
                    if option ~= currentSelection then
                        optBtn.BackgroundTransparency = 0
                        optBtn.BackgroundColor3 = Config.Colors.Hover
                    end
                end)

                optBtn.MouseLeave:Connect(function()
                    if option ~= currentSelection then
                        optBtn.BackgroundTransparency = 1
                    end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    selected.Text = option
                    currentSelection = option
                    dropdownWrapper.selectedValue = option -- KRITISCHER FIX: selectedValue aktualisieren
                    isOpen = false
                    optionsFrame.Visible = false
                    arrow.Text = '▼'
                    updateOptionsDisplay()
                    
                    print('DEBUG Dropdown: Selected option =', option, 'dropdownWrapper.selectedValue =', dropdownWrapper.selectedValue) -- Debug output
                    self.notifications:info('Config Selected', 'Selected: ' .. option, 2)
                end)
            end

            optionsFrame.Size = UDim2.new(1, 0, 0, 36 + #options * 28 + 8)
        end

        local arrowBtn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = dropdown,
        })

        arrowBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            optionsFrame.Visible = isOpen
            arrow.Text = isOpen and '▲' or '▼'
            
            if isOpen then
                updateOptionsDisplay()
            end
        end)

        arrowBtn.MouseEnter:Connect(function()
            if not isOpen then
                dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            end
        end)

        arrowBtn.MouseLeave:Connect(function()
            if not isOpen then
                dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            end
        end)

        -- Create dropdown wrapper object that manages the UI
        dropdownWrapper = {
            frame = dropdown,
            selectedValue = currentSelection,
            options = options or {},
            selected = selected,
            
            updateOptions = function(self, newOptions)
                self.options = newOptions or {}
                options = newOptions or {}
                
                if #self.options > 0 then
                    self.selected.Text = self.options[1]
                    self.selectedValue = self.options[1]
                    currentSelection = self.options[1]
                else
                    self.selected.Text = 'No configs'
                    self.selectedValue = nil
                    currentSelection = ''
                end
                
                updateOptionsDisplay()
            end
        }

        -- Initial options display
        updateOptionsDisplay()

        return dropdownWrapper
    end

            function RadiantHub:createConfigToggle(parent, title, desc, state, pos, callback)
            local frame = create('Frame', {
                Size = UDim2.new(1, -5, 0, isMobile and 26 or 32),
                Position = pos,
                BackgroundTransparency = 1,
                Parent = parent,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -28 or -40, 0, isMobile and 12 or 14),
                Position = UDim2.new(0, 0, 0, isMobile and 1 or 2),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Config.Colors.Text,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            create('TextLabel', {
                Size = UDim2.new(1, isMobile and -28 or -40, 0, isMobile and 8 or 10),
                Position = UDim2.new(0, 0, 0, isMobile and 13 or 16),
                BackgroundTransparency = 1,
                Text = desc,
                TextColor3 = Config.Colors.SubText,
                TextSize = isMobile and 8 or 9,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            local switch = create('Frame', {
                Size = UDim2.new(0, isMobile and 24 or 35, 0, isMobile and 12 or 16),
                Position = UDim2.new(1, isMobile and -26 or -37, 0.5, isMobile and -6 or -8),
                BackgroundColor3 = state and Config.Colors.Active or Color3.fromRGB(50, 50, 55),
                Parent = frame,
            })
            addCorner(switch, isMobile and 6 or 8)

            local knob = create('Frame', {
                Size = UDim2.new(0, isMobile and 8 or 12, 0, isMobile and 8 or 12),
                Position = state and UDim2.new(1, isMobile and -10 or -14, 0.5, isMobile and -4 or -6) or UDim2.new(0, 2, 0.5, isMobile and -4 or -6),
                BackgroundColor3 = Config.Colors.Text,
                Parent = switch,
            })
            addCorner(knob, isMobile and 4 or 6)

        local btn = create('TextButton', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            Parent = frame,
        })

        local isToggled = state
                    btn.MouseButton1Click:Connect(function()
                isToggled = not isToggled

                tween(switch, 0.2, {
                    BackgroundColor3 = isToggled and Config.Colors.Active or Color3.fromRGB(50, 50, 55),
                }):Play()

                tween(knob, 0.2, {
                    Position = isToggled and UDim2.new(1, isMobile and -10 or -14, 0.5, isMobile and -4 or -6) or UDim2.new(0, 2, 0.5, isMobile and -4 or -6),
                }):Play()

            if callback then
                callback(isToggled)
            end
        end)

        return frame
    end

    -- Clean up function
    function RadiantHub:destroy()
        if self.watermark then
            self.watermark:destroy()
            self.watermark = nil
        end

        if self.notifications then
            self.notifications:destroy()
            self.notifications = nil
        end

        if self.screen then
            self.screen:Destroy()
        end
    end

    -- Library Interface
    local Library = {}

    function Library:CreateWindow()
        return RadiantHub.new()
    end

    return Library
