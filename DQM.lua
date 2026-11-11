local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService= game:GetService("MarketplaceService")
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local LocalPlayer = Players.LocalPlayer
local char, hrp, hum
local farmActive   = false
local farmThread   = nil
local farmCycles   = 0
local farmStatus   = "Inactivo"
local isRespawning = false
local farmLoop     = nil
local killMove     = nil
local saveTool     = nil
local deathConn    = nil
local healthConn   = nil

local function onDeathDetected()
    if not farmActive or isRespawning then return end
    isRespawning = true
    farmStatus = "Muerte detectada (0/100 HP), esperando reaparicion..."
    if killMove then killMove() end
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    local newChar = LocalPlayer.CharacterAdded:Wait()
    task.wait(1.0)
    if char ~= newChar then
        char = newChar
        hrp  = newChar:WaitForChild("HumanoidRootPart")
        hum  = newChar:WaitForChild("Humanoid")
    end
    task.wait(1.5)
    if farmActive then
        isRespawning = false
        farmStatus = "Reaparecido, reiniciando auto farm..."
        if saveTool then saveTool() end
        if farmLoop then
            farmThread = task.spawn(farmLoop)
        end
    else
        isRespawning = false
    end
end

local function refreshChar(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")
    hum  = c:WaitForChild("Humanoid")
    if deathConn then pcall(function() deathConn:Disconnect() end); deathConn = nil end
    if healthConn then pcall(function() healthConn:Disconnect() end); healthConn = nil end
    deathConn = hum.Died:Connect(onDeathDetected)
    healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then
            onDeathDetected()
        end
    end)
end

refreshChar(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(function(c)
    refreshChar(c)
    if farmActive and not isRespawning then
        task.delay(2.0, function()
            if farmActive and not isRespawning then
                if killMove then killMove() end
                if farmThread then task.cancel(farmThread); farmThread = nil end
                if farmLoop then farmThread = task.spawn(farmLoop) end
            end
        end)
    end
end)

local Window = WindUI:CreateWindow({
    Title        = "Z Dxlan - B Q M <font color='#FFD700'>  [Premium]  </font>",
    Author       = "",
    Folder       = "BQM",
    Acrylic      = false,
    Transparent  = false,
    NewElements  = true,
    Background   = "https://raw.githubusercontent.com/95msxz/Proyect/heads/main/992973417865696516.jpg",
    BackgroundImageTransparency = 0.35,
    HideSearchBar = false,
    OpenButton   = {
        Title = "Z Dxlan - B Q M",
        Icon = "",
        IconSize = 9,
        CornerRadius = UDim.new(1),
        StrokeThickness = 2,
        Enabled = true,
        OnlyMobile = false,
        Draggable = true,
        Scale = 0.9,
        Color = ColorSequence.new(Color3.fromHex("#110070"), Color3.fromHex("#300364"))
    },
    Topbar = { Height = 44, ButtonsType = "Default" }
})

local FarmSection   = Window:Section({ Title = "Auto Farms",      Icon = "solar:box-bold",     Opened = true  })
local MainSection   = Window:Section({ Title = "Principal",      Icon = "solar:star-bold",     Opened = true  })
local ConfigSection = Window:Section({ Title = "Ajustes/Others", Icon = "solar:settings-bold", Opened = true  })
local Tabs = {
    Inicio   = MainSection:Tab({ Title = "Inicio",    Icon = "solar:home-bold"      }),
    Farm     = FarmSection:Tab({ Title = "AutoFarm 1",      Icon = "solar:leaf-bold"}),
    Farm2    = FarmSection:Tab({ Title = "AutoFarm 2",      Icon = "solar:leaf-bold"}),
    Combat   = MainSection:Tab({ Title = "Combat",    Icon = "solar:target-bold"    }),
    Esp      = MainSection:Tab({ Title = "Esp",       Icon = "solar:eye-bold"       }),
    Movement = MainSection:Tab({ Title = "Movement",  Icon = "solar:walking-bold"   }),
    Ajustes  = ConfigSection:Tab({ Title = "Ajustes", Icon = "solar:settings-bold"  })
}

Tabs.Ajustes:Section({ Title = "Personalización", Icon = "solar:palette-bold", Opened = true })
Tabs.Ajustes:Dropdown({ Title = "Color del menú", Values = {"Midnight","Dark","Bloom","Rose","Sea","Sky","Amber"}, Value = "Dark", Callback = function(t) WindUI:SetTheme(t) end })
Tabs.Ajustes:Space()
Tabs.Ajustes:Dropdown({ Title = "Tipo de letra", Values = {"BuilderSans","Montserrat","Nunito","Oswald","PermanentMarker","LuckiestGuy"}, Value = "PermanentMarker", Callback = function(f) WindUI:SetFont("rbxasset://fonts/families/" .. f .. ".json") end })

pcall(function() Tabs.Inicio:Select() end)

Tabs.Inicio:Section({ Title = "Perfil", Icon = "solar:user-bold" })
local execName = "Desconocido"
pcall(function() execName = identifyexecutor and identifyexecutor() or "Desconocido" end)
Tabs.Inicio:Paragraph({
    Title = "Usuario: " .. LocalPlayer.DisplayName,
    Desc  = "Usuario: @" .. LocalPlayer.Name
         .. "\nID: " .. LocalPlayer.UserId
         .. "\nEdad de la cuenta: " .. LocalPlayer.AccountAge .. " días",
    Image     = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420",
    ImageSize = 48
})
Tabs.Inicio:Paragraph({ Title = "Ejecutor", Desc = ": " .. execName })
Tabs.Inicio:Section({ Title = "Información del Servidor", Icon = "solar:server-bold" })
local gameNameStr = "Desconocido"
pcall(function() gameNameStr = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
Tabs.Inicio:Paragraph({
    Title     = "Juego Actual",
    Desc      = gameNameStr .. "\nPlace ID: " .. game.PlaceId,
    Image     = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
    ImageSize = 48
})
Tabs.Inicio:Section({ Title = "Comunidad Z Nexus", Icon = "solar:users-group-rounded-bold" })
Tabs.Inicio:Paragraph({
    Title   = "Únete al Discord",
    Desc    = "Comunidad oficial de Z Nexus. Soporte directo, actualizaciones exclusivas, avisos de nuevos scripts y ayuda con el menú.",
    Image = "https://cdn.discordapp.com/embed/avatars/1.png",
    ImageSize = 48,
    Buttons = {{
        Title    = "Copiar enlace",
        Icon     = "solar:clipboard-list-bold",
        Callback = function()
            setclipboard("https://discord.gg/hQeCQsKqJm")
        end,
    }},
})

local COORD_PASO      = Vector3.new(160.889, 255.018, 251.832)
local COORD_JOIN      = Vector3.new(165.832, 255.118, 203.553)
local COORD_GOLDENBOX = Vector3.new(118.326, 237.095, 210.935)
local COORD_ENTREGA   = Vector3.new(128.624, 255.118, 184.667)
local COORD_ATM       = Vector3.new(95.339, 255.118, 166.094)
local FARM_SPEED      = 15
local autoDepositEnabled = false
local autoDepositAmount  = 2000
local BOX_WAIT_TIME   = 4.5
local BOX_TO_CARRY    = 3
local seatConn   = nil
local standConn  = nil
local savedTool  = nil
local activeMove = nil

killMove = function()
    if activeMove then pcall(function() activeMove:Disconnect() end); activeMove = nil end
    if seatConn   then pcall(function() seatConn:Disconnect()   end); seatConn   = nil end
    if standConn  then pcall(function() standConn:Disconnect()  end); standConn  = nil end
end

saveTool = function()
    if char then
        savedTool = char:FindFirstChildOfClass("Tool")
    end
end

local function blockSeat(secs)
    if seatConn then pcall(function() seatConn:Disconnect() end) end
    seatConn = hum.Seated:Connect(function(isSeated)
        if isSeated then task.defer(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
    end)
    if secs then task.delay(secs, function()
        if seatConn then pcall(function() seatConn:Disconnect() end); seatConn = nil end
    end) end
end

local function tweenTo(target, useNoclip)
    if not farmActive then return false end
    local start = hrp.Position
    local dist  = (start - target).Magnitude
    if dist < 0.5 then
        hrp.CFrame = CFrame.new(target)
        return true
    end
    local oldCollide = {}
    if useNoclip then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                oldCollide[v] = v.CanCollide
                v.CanCollide = false
            end
        end
    end
    local duration = dist / (FARM_SPEED * 4)
    if duration < 0.05 then duration = 0.05 end
    local elapsed  = 0
    local done     = false
    local ok       = true
    blockSeat(duration + 2)
    activeMove = RunService.Stepped:Connect(function(_, dt)
        if not farmActive then
            if activeMove then activeMove:Disconnect(); activeMove = nil end
            done = true; ok = false
            return
        end
        elapsed += dt
        local t = math.min(elapsed / duration, 1)
        hrp.CFrame = CFrame.new(start:Lerp(target, t))
        if t >= 1 then
            if activeMove then activeMove:Disconnect(); activeMove = nil end
            done = true
        end
    end)
    while not done do task.wait() end
    if useNoclip then
        for part, state in pairs(oldCollide) do
            if part and part.Parent then
                part.CanCollide = state
            end
        end
    end
    return ok
end

local function holdPosition(target, duration, useNoclip)
    if not farmActive then return false end
    local startTime = tick()
    local maxRetries = 12
    local retries = 0
    while farmActive and (tick() - startTime < duration) do
        if not hrp or not hrp.Parent then return false end
        local dist = (hrp.Position - target).Magnitude
        if dist > 3.0 then
            retries += 1
            if retries > maxRetries then break end
            startTime = tick()
            tweenTo(target, useNoclip)
            task.wait(0.1)
        else
            hrp.CFrame = CFrame.new(target)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.08)
        end
    end
    if hrp and hrp.Parent then
        hrp.CFrame = CFrame.new(target)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    return farmActive and (hrp and (hrp.Position - target).Magnitude <= 3.5)
end

local function getAttr(attr)
    return LocalPlayer:GetAttribute(attr)
end

local function waitAttr(attr, value, timeout)
    local t = 0
    while getAttr(attr) ~= value do
        if not farmActive then return false end
        task.wait(0.15)
        t += 0.15
        if t >= timeout then return false end
    end
    return true
end

local function findGoldenBox()
    local best, bestPos, bestObj, bestDist = nil, nil, nil, math.huge
    local myPos = (hrp and hrp.Position) or Vector3.zero
    local function evaluateCandidate(obj)
        if not obj or not obj:IsDescendantOf(workspace) then return end
        local name = obj.Name
        if name:find("Electronics") or name:find("Normal") or name:find("Sunflower") then
            return
        end
        if name ~= "GoldenBox" and name ~= "GoldenBoxPileForJob" and name ~= "GoldCrate" and not name:find("GoldenBox") then
            return
        end
        local pp = obj:FindFirstChild("MD_QuickPickup")
            or obj:FindFirstChildOfClass("ProximityPrompt")
            or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt", true))
        if not pp or not pp.Enabled or not pp.Parent then return end
        if pp.ObjectText and pp.ObjectText:find("Electronics") then return end
        local pos = nil
        if obj:IsA("BasePart") then
            pos = obj.Position
        elseif obj:IsA("Model") then
            local okPivot, pivot = pcall(function() return obj:GetPivot() end)
            if okPivot and pivot then pos = pivot.Position end
            if not pos and obj.PrimaryPart then pos = obj.PrimaryPart.Position end
        end
        if pos then
            local d = (myPos - pos).Magnitude
            if d < bestDist then
                bestDist = d
                best = pp
                bestPos = pos
                bestObj = obj
            end
        end
    end
    pcall(function()
        local job = workspace:FindFirstChild("Map", true)
        if job then
            local shelf = job:FindFirstChild("ShelfStockingJob", true)
            if shelf then
                local gb = shelf:FindFirstChild("GoldenBox")
                if gb then evaluateCandidate(gb) end
                local pile = shelf:FindFirstChild("GoldenBoxPileForJob")
                if pile then evaluateCandidate(pile) end
            end
        end
    end)
    if best then return best, bestPos, bestObj end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GoldenBox" or obj.Name == "GoldenBoxPileForJob" or obj.Name == "GoldCrate" then
            evaluateCandidate(obj)
        end
    end
    return best, bestPos, bestObj
end

local function getDeliveryTarget()
    local target = getAttr("MD_QuickStockTarget")
    if typeof(target) == "Vector3" then return target end
    return nil
end

local function doDeposit(amount)
    if not farmActive then return end
    local cash = LocalPlayer:GetAttribute("Cash") or 0
    if cash < amount then return end
    local toDeposit = math.min(amount, cash)
    farmStatus = "[ATM] Yendo al cajero..."
    tweenTo(COORD_ATM, true)
    farmStatus = "[ATM] Confirmando posicion (3s anti-cheat)..."
    if not holdPosition(COORD_ATM, 3, true) then return end
    task.wait(0.2)
    local prompt = nil
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and (p.Name == "MD_ATMPrompt" or (p.Parent and p.Parent.Name == "MD_ATMInteraction")) then
            local pos = p.Parent and p.Parent:IsA("BasePart") and p.Parent.Position
            if pos and (hrp.Position - pos).Magnitude < 20 then
                prompt = p
                break
            end
        end
    end
    if prompt then
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 25
            if fireproximityprompt then
                fireproximityprompt(prompt, 0)
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                task.wait(math.max(prompt.HoldDuration or 0, 0.1) + 0.1)
                prompt:InputHoldEnd()
            end
        end)
    end
    task.wait(0.35)
    farmStatus = "[ATM] Depositando $" .. toDeposit .. "..."
    local atmRemote = ReplicatedStorage:FindFirstChild("MD_ATMRemote")
    if atmRemote then
        atmRemote:FireServer("Deposit", toDeposit)
    end
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local atmGui = pg and pg:FindFirstChild("MD_ATMGui")
        if atmGui and atmGui:FindFirstChild("Panel") then
            atmGui.Panel.Visible = false
        end
    end)
    local waited = 0
    local prevCash = cash
    while (LocalPlayer:GetAttribute("Cash") or 0) >= prevCash and waited < 2.0 do
        task.wait(0.1)
        waited += 0.1
    end
    farmStatus = "[ATM] Deposito de $" .. toDeposit .. " completado"
    task.wait(0.3)
end

farmLoop = function()
    local Remote = ReplicatedStorage:FindFirstChild("MD_Quick11Remote")
    if not Remote then
        farmActive = false
        return
    end
    farmCycles  = 0
    farmStatus  = "Limpiando estado anterior..."
    killMove()
    pcall(function() Remote:FireServer("Leave") end)
    task.wait(1.2)
    if (getAttr("MD_QuickStockBoxCount") or 0) > 0 and getAttr("MD_Quick11Active") ~= true then
        pcall(function() LocalPlayer:SetAttribute("MD_QuickStockBoxCount", 0) end)
        task.wait(0.2)
    end
    if not farmActive then return end
    farmStatus = "[Setup 1/3] Yendo a punto de paso..."
    if not tweenTo(COORD_PASO, true) then farmActive = false return end
    task.wait(0.25)
    farmStatus = "[Setup 2/3] Yendo a JOIN JOB..."
    tweenTo(COORD_JOIN, true)
    farmStatus = "[Setup 2/3] Confirmando posicion (2s anti-cheat)..."
    if not holdPosition(COORD_JOIN, 2, true) then farmActive = false return end
    task.wait(0.2)
    farmStatus = "[Setup 3/3] Aceptando trabajo..."
    local joined = false
    for attempt = 1, 6 do
        if not farmActive then break end
        if getAttr("MD_Quick11Active") == true then
            joined = true
            break
        end
        farmStatus = "[Setup 3/3] Aceptando trabajo (" .. attempt .. "/6)..."
        pcall(function() Remote:FireServer("Join") end)
        local waited = 0
        while farmActive and getAttr("MD_Quick11Active") ~= true and waited < 1.4 do
            task.wait(0.15)
            waited += 0.15
        end
        if getAttr("MD_Quick11Active") == true then
            joined = true
            break
        end
        pcall(function()
            hrp.CFrame = CFrame.new(COORD_JOIN)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if not joined and getAttr("MD_Quick11Active") ~= true then
        farmActive = false
        return
    end
    task.wait(0.3)
    while farmActive do
        farmCycles += 1
        farmStatus = "Ciclo #" .. farmCycles
        farmStatus = "[1/4] Yendo a zona de cajas..."
        if not tweenTo(COORD_GOLDENBOX) then break end
        task.wait(0.4)
        farmStatus = "[2/4] Agarrando GoldenBoxes..."
        local maxCarry = math.clamp(getAttr("MD_ShelfLevel") or 1, 1, 5)
        local toCarry  = math.min(BOX_TO_CARRY, maxCarry)
        local boxesTaken = 0
        local stall = 0
        while farmActive and boxesTaken < toCarry do
            local curCount = getAttr("MD_QuickStockBoxCount") or 0
            if curCount >= toCarry then
                boxesTaken = curCount
                break
            end
            local pp, pos = findGoldenBox()
            if pp and pos then
                local grabbed = false
                for attempt = 1, 6 do
                    if not farmActive then break end
                    if not pp or not pp.Parent or not pp.Enabled then break end
                    local prevCount = getAttr("MD_QuickStockBoxCount") or 0
                    pcall(function()
                        pp.RequiresLineOfSight = false
                        if pp.MaxActivationDistance < 30 then
                            pp.MaxActivationDistance = 30
                        end
                    end)
                    pcall(function()
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 1.2, 0))
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                    task.wait(0.18)
                    if attempt % 2 == 1 and fireproximityprompt then
                        pcall(function() fireproximityprompt(pp, 0) end)
                        pcall(function() fireproximityprompt(pp) end)
                    else
                        pcall(function()
                            local hold = math.max(pp.HoldDuration or 0, 0.05)
                            pp:InputHoldBegin()
                            task.wait(hold + 0.12)
                            pp:InputHoldEnd()
                        end)
                    end
                    local waited = 0
                    while farmActive and (getAttr("MD_QuickStockBoxCount") or 0) == prevCount and waited < 1.8 do
                        task.wait(0.1)
                        waited += 0.1
                    end
                    local newCount = getAttr("MD_QuickStockBoxCount") or 0
                    if newCount > prevCount then
                        boxesTaken = newCount
                        grabbed = true
                        farmStatus = "[2/4] Caja " .. boxesTaken .. "/" .. toCarry .. " agarrada"
                        task.wait(0.2)
                        break
                    end
                    task.wait(0.2)
                    pp, pos = findGoldenBox()
                    if not pp then break end
                end
                if not grabbed and farmActive then
                    stall += 1
                    if stall >= 3 then
                        farmStatus = "[2/4] Box no responde, esperando respawn..."
                        task.wait(3)
                        stall = 0
                    end
                else
                    stall = 0
                    task.wait(0.25)
                end
            else
                farmStatus = "[2/4] Esperando GoldenBoxes..."
                task.wait(1.2)
                stall += 1
                if stall >= 9 then break end
            end
        end
        if not farmActive then break end
        local finalBoxCount = getAttr("MD_QuickStockBoxCount") or 0
        if finalBoxCount == 0 then
            farmStatus = "No se agarraron cajas, reintentando..."
            task.wait(2)
            continue
        end
        farmStatus = "[3/4] Yendo a zona de entrega..."
        if not tweenTo(COORD_ENTREGA) then break end
        task.wait(0.4)
        local deliveredCount = 0
        while farmActive and (getAttr("MD_QuickStockBoxCount") or 0) > 0 do
            if getAttr("MD_Quick11Active") ~= true then
                farmStatus = "Job terminó inesperadamente"
                break
            end
            local delivTarget = getDeliveryTarget()
            local waitT = 0
            while typeof(delivTarget) ~= "Vector3" and waitT < 8 do
                if not farmActive then break end
                task.wait(0.2); waitT += 0.2
                delivTarget = getDeliveryTarget()
            end
            if typeof(delivTarget) ~= "Vector3" then
                farmStatus = "Sin target de entrega, reintentando ciclo..."
                break
            end
            deliveredCount += 1
            farmStatus = "[4/4] Entregando caja " .. deliveredCount .. " → círculo azul"
            local standTarget = delivTarget + Vector3.new(0, 2.5, 0)
            if not tweenTo(standTarget, true) then break end
            farmStatus = "[4/4] Parado en círculo... (" .. BOX_WAIT_TIME .. "s)"
            local prevBoxes  = getAttr("MD_QuickStockBoxCount") or 0
            local standStart = tick()
            if standConn then pcall(function() standConn:Disconnect() end) end
            standConn = RunService.Heartbeat:Connect(function()
                if not farmActive then return end
                local drift = (hrp.Position - standTarget).Magnitude
                if drift > 0.5 then
                    hrp.CFrame = CFrame.new(hrp.Position:Lerp(standTarget, 0.3))
                end
            end)
            local delivered = false
            while farmActive and tick() - standStart < BOX_WAIT_TIME + 1 do
                task.wait(0.1)
                if (getAttr("MD_QuickStockBoxCount") or 0) < prevBoxes then
                    delivered = true
                    break
                end
            end
            if standConn then pcall(function() standConn:Disconnect() end); standConn = nil end
            if delivered then
                farmStatus = "✓ Caja " .. deliveredCount .. " entregada (+$100)"
                task.wait(0.2)
            else
                farmStatus = "⚠ Caja " .. deliveredCount .. " no detectada, revisando..."
                task.wait(0.5)
            end
        end
        farmStatus = "[Ciclo] #" .. farmCycles .. " completo"
        if autoDepositEnabled and farmActive then
            local currentCash = LocalPlayer:GetAttribute("Cash") or 0
            if currentCash >= autoDepositAmount then
                doDeposit(autoDepositAmount)
            end
        end
    end
    killMove()
    farmStatus = "Inactivo"
    farmActive = false
end

Tabs.Farm:Section({ Title = "BOX | Auto Box", Icon = "solar:box-bold", Opened = true })
Tabs.Farm:Space()
Tabs.Farm:Toggle({
    Title   = "Auto Box",
    Desc    = "Activa el farm automático de GoldenBox en Quick11",
    Icon    = "solar:box-minimalistic-bold",
    Value   = false,
    Callback = function(state)
        if state then
            if farmActive then return end
            farmCycles = 0
            farmStatus = "Iniciando..."
            farmActive = true
            saveTool()
            farmThread = task.spawn(farmLoop)
        else
            farmActive = false
            killMove()
            if farmThread then
                task.cancel(farmThread)
                farmThread = nil
            end
            farmCycles = 0
            farmStatus = "Inactivo"
            pcall(function()
                local Remote = ReplicatedStorage:FindFirstChild("MD_Quick11Remote")
                if Remote then Remote:FireServer("Leave") end
            end)
            if (getAttr("MD_QuickStockBoxCount") or 0) > 0 then
                pcall(function() LocalPlayer:SetAttribute("MD_QuickStockBoxCount", 0) end)
            end
        end
    end
})
Tabs.Farm:Toggle({
    Title   = "Auto Depósito",
    Desc    = "Va al cajero automáticamente al llegar a la meta",
    Icon    = "solar:card-send-bold",
    Value   = false,
    Callback = function(state)
        autoDepositEnabled = state
    end
})
Tabs.Farm:Input({
    Title       = "Meta de Cash",
    Desc        = "Cantidad para ir a depositar (Ej. 2000)",
    Value       = "2000",
    Placeholder = "2000",
    Callback    = function(val)
        local num = tonumber(val:match("%d+"))
        if num and num > 0 then
            autoDepositAmount = num
        end
    end
})
Tabs.Farm:Slider({
    Title   = "Cajas",
    Desc    = "Cuántas GoldenBox agarrar antes de entregar.",
    Icon    = "solar:box-bold",
    Step    = 1,
    Value   = { Min = 1, Max = 5, Default = 3 },
    Callback = function(v) BOX_TO_CARRY = v end
})

local SPEED_LEVELS = {
    ["Level 1"] = 15,
    ["Level 2"] = 25,
    ["Level (MAX)"] = 45,
}
Tabs.Farm:Dropdown({
    Title    = "Velocidad de farmeo",
    Desc     = "Nivel de velocidad del farm",
    Icon     = "solar:running-bold",
    Values   = { "Level 1", "Level 2", "Level (MAX)" },
    Value    = "Level 1",
    Callback = function(v)
        FARM_SPEED = SPEED_LEVELS[v] or 15
    end
})

RunService.Heartbeat:Connect(function()
    if not farmActive then return end
    if hum and hum:GetState() == Enum.HumanoidStateType.Seated then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

local COORD_FISH_SHOP = Vector3.new(-146.889, 255.053, 157.648)
local COORD_SELL_WP1  = Vector3.new(-274.209, 256.099, 431.927)
local COORD_SELL_WP2  = Vector3.new(-252.696, 256.146, 380.063)
local MAX_FISH_CAPACITY = 15

local FISH_ZONES = {
    ["Nivel 0"]  = CFrame.new(Vector3.new(286.760, 243.487, -904.824), Vector3.new(285.896, 243.487, -904.320)),
    ["Nivel 10"] = CFrame.new(Vector3.new(483.993, 240.174, -1057.464), Vector3.new(484.497, 240.119, -1056.602)),
    ["Nivel 20"] = CFrame.new(Vector3.new(-409.789, 233.818, 734.749), Vector3.new(-409.854, 233.831, 735.747)),
    ["Nivel 25"] = CFrame.new(Vector3.new(148.539, 233.155, 773.989), Vector3.new(149.538, 233.126, 773.972)),
    ["Nivel 60"] = CFrame.new(Vector3.new(1526.745, 234.338, 948.207), Vector3.new(1527.438, 234.487, 948.911)),
}
local fish2Zone = "Nivel 0"
local BAIT_BUY_QTY   = 50
local fishSavedOrigin = nil
local activeFishMove = nil

local function killFishMove()
    if activeFishMove then
        pcall(function() activeFishMove:Disconnect() end)
        activeFishMove = nil
    end
end

local ROD_TIERS = {
    FishingRodUltimate = 4,
    FishingRodAdvanced = 3,
    FishingRodPro      = 2,
    FishingRodRegular  = 1,
}
local ROD_BAIT = {
    FishingRodUltimate = "WormtecUltimate",
    FishingRodAdvanced = "WormtecPro",
    FishingRodPro      = "WormtecPro",
    FishingRodRegular  = "WormtecRegular",
}
local ROD_PRICES = {
    FishingRodUltimate = 5000,
    FishingRodAdvanced = 2300,
    FishingRodPro      = 800,
    FishingRodRegular  = 100,
}
local ROD_BUDGETS = {
    FishingRodRegular  = 1100,
    FishingRodPro      = 2050,
    FishingRodAdvanced = 3800,
    FishingRodUltimate = 6500,
}
local ROD_DISPLAY_NAMES = {
    FishingRodRegular  = "Fishing Rod Regular",
    FishingRodPro      = "Fishing Rod Pro",
    FishingRodAdvanced = "Fishing Rod Advanced",
    FishingRodUltimate = "Fishing Rod Ultimate",
}
local BAIT_PRICES = {
    WormtecRegular  = 200,
    WormtecPro      = 250,
    WormtecUltimate = 500,
}
local selectedRodToBuy = "FishingRodPro"
local autoFishToggle = nil

local BAIT_NAMES = { WormtecUltimate = true, WormtecPro = true, WormtecRegular = true }

local fish2Active = false
local fish2Thread = nil
local F2_SPEED_LEVELS = {
    ["Nivel 1"] = 20,
    ["Nivel 2"] = 40,
}
local F2_SPEED = 20
local antiSkidsActive = false
local isSafeHealing = false
local COORD_SAFE_HEAL = Vector3.new(489.397, 256.118, -17.302)
local fishHoldConn  = nil
local fishEventConn = nil
local isSellingFish = false
local lastSellTimestamp = 0
local lastSellConfirmed = false

local function getPlayerCash()
    local c = LocalPlayer:GetAttribute("Cash")
    if typeof(c) == "number" then return c end
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local cv = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money")
        if cv and typeof(cv.Value) == "number" then return cv.Value end
    end
    return tonumber(c) or 0
end

local function turnOffAutoFish(msg)
    fish2Active = false
    if fish2Thread then
        task.cancel(fish2Thread)
        fish2Thread = nil
    end
    killFishMove()
    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
    if fishEventConn then pcall(function() fishEventConn:Disconnect() end); fishEventConn = nil end
    if hrp and hrp.Parent then hrp.Anchored = false end
    local standEnd = workspace:FindFirstChild("MD_FishStand_Safe")
    if standEnd then pcall(function() standEnd:Destroy() end) end

    if msg then
        pcall(function()
            WindUI:Notify({
                Title = "Dinero Insuficiente",
                Content = msg,
                Duration = 5,
                Icon = "solar:danger-triangle-bold"
            })
        end)
    end

    if autoFishToggle then
        pcall(function()
            if typeof(autoFishToggle.Set) == "function" then
                autoFishToggle:Set(false)
            elseif typeof(autoFishToggle.SetValue) == "function" then
                autoFishToggle:SetValue(false)
            end
        end)
    end
end

local function fish2Move(targetPos)
    if not fish2Active then return false end
    if not hrp or not hrp.Parent then return false end

    local targetVector = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local start = hrp.Position
    local dist  = (start - targetVector).Magnitude
    if dist < 0.5 then
        if typeof(targetPos) == "CFrame" then
            hrp.CFrame = targetPos
        else
            hrp.CFrame = CFrame.new(targetPos)
        end
        return true
    end

    local underStart  = Vector3.new(start.X,  start.Y  - 10, start.Z)
    local underTarget = Vector3.new(targetVector.X, targetVector.Y - 10, targetVector.Z)

    local duration = dist / (F2_SPEED * 4)
    if duration < 0.05 then duration = 0.05 end
    local elapsed = 0
    local done    = false
    local ok      = true

    local scConn = hum.Seated:Connect(function(s)
        if s then task.defer(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
    end)

    killFishMove()
    activeFishMove = RunService.Heartbeat:Connect(function(dt)
        if not fish2Active then
            killFishMove(); done = true; ok = false
            return
        end
        local currentDuration = math.max(dist / (F2_SPEED * 4), 0.05)
        elapsed += dt
        local t = math.min(elapsed / currentDuration, 1)
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(underStart:Lerp(underTarget, t))
        if t >= 1 then
            killFishMove(); done = true
        end
    end)

    while not done do task.wait() end

    scConn:Disconnect()
    if ok then
        if typeof(targetPos) == "CFrame" then
            hrp.CFrame = targetPos
        else
            hrp.CFrame = CFrame.new(targetPos)
        end
    end
    return ok
end

local function fish2HoldPosition(targetPos, duration)
    if not fish2Active then return false end
    local targetVector = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local startTime = tick()
    local maxRetries = 25
    local retries = 0
    while fish2Active and (tick() - startTime < duration) do
        if not hrp or not hrp.Parent then return false end
        local dist = (hrp.Position - targetVector).Magnitude
        if dist > 3.8 then
            retries += 1
            if retries > maxRetries then break end
            startTime = tick()
            fish2Move(targetPos)
            task.wait(0.1)
        else
            if typeof(targetPos) == "CFrame" then
                hrp.CFrame = targetPos
            else
                hrp.CFrame = CFrame.new(targetPos)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.08)
        end
    end
    if hrp and hrp.Parent then
        if typeof(targetPos) == "CFrame" then
            hrp.CFrame = targetPos
        else
            hrp.CFrame = CFrame.new(targetPos)
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    return fish2Active and (hrp and (hrp.Position - targetVector).Magnitude <= 3.8)
end

local function fish2GlideTo(target, speed)
    if not hrp or not hrp.Parent then return false end
    local start = hrp.Position
    local dist = (start - target).Magnitude
    if dist < 1 then
        hrp.CFrame = CFrame.new(target)
        return true
    end
    local underStart  = Vector3.new(start.X,  start.Y  - 10, start.Z)
    local underTarget = Vector3.new(target.X, target.Y - 10, target.Z)
    local duration = math.max(dist / (speed * 4), 0.05)
    local elapsed = 0
    local done = false

    killFishMove()
    activeFishMove = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        local t = math.min(elapsed / duration, 1)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(underStart:Lerp(underTarget, t))
        if t >= 1 then
            killFishMove()
            done = true
        end
    end)

    while not done and (hum and hum.Health > 0) do
        task.wait()
    end

    if hrp and hrp.Parent then
        hrp.CFrame = CFrame.new(target)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    return true
end

local function safeHealRoutine()
    if isSafeHealing or not fish2Active then return end
    isSafeHealing = true

    local fishRemote = ReplicatedStorage:FindFirstChild("MD_FishingRemote")
    if fishRemote then
        pcall(function() fishRemote:FireServer("Cancel") end)
    end

    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
    if hrp and hrp.Parent then hrp.Anchored = false end
    task.wait(0.1)

    fish2GlideTo(COORD_SAFE_HEAL, 75)

    if hrp and hrp.Parent then
        hrp.CFrame = CFrame.new(COORD_SAFE_HEAL)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Anchored = true
    end

    while fish2Active and antiSkidsActive and hum and hum.Parent and hum.Health < 100 and hum.Health > 0 do
        task.wait(0.25)
    end

    if not fish2Active or not hum or hum.Health <= 0 then
        isSafeHealing = false
        return
    end

    if hrp and hrp.Parent then hrp.Anchored = false end
    task.wait(0.1)

    local targetCFrame = FISH_ZONES[fish2Zone] or FISH_ZONES["Nivel 0"]

    local standPart = workspace:FindFirstChild("MD_FishStand_Safe")
    if not standPart then
        standPart = Instance.new("Part")
        standPart.Name = "MD_FishStand_Safe"
        standPart.Size = Vector3.new(15, 2, 15)
        standPart.Anchored = true
        standPart.CanCollide = true
        standPart.Transparency = 1
        standPart.Parent = workspace
    end
    standPart.CFrame = CFrame.new(targetCFrame.Position - Vector3.new(0, 3.1, 0))

    fish2Move(targetCFrame)

    hrp.CFrame = targetCFrame
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.Anchored = true

    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end) end
    fishHoldConn = RunService.Heartbeat:Connect(function()
        if not fish2Active or not hrp or not hrp.Parent then return end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if not hrp.Anchored then hrp.Anchored = true end
    end)

    local curRod = f2_getBestRod()
    local curBait = f2_getBait()
    if curRod then
        pcall(function() hum:EquipTool(curRod) end)
        task.wait(0.2)
    end
    if curRod and curBait then
        ensureBaitLoaded(curRod, curBait)
    end

    isSafeHealing = false
end

local function f2_setupHealthWatch()
    if hum then
        hum.HealthChanged:Connect(function(hp)
            if antiSkidsActive and not isSafeHealing and fish2Active and hp < 80 and hp > 0 then
                task.spawn(safeHealRoutine)
            end
        end)
    end
end
f2_setupHealthWatch()

local function f2_findItem(itemName)
    if not itemName then return nil end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        local it = bp:FindFirstChild(itemName)
        if it then return it end
    end
    local ch = LocalPlayer.Character or char
    if ch then
        local it = ch:FindFirstChild(itemName)
        if it and it:IsA("Tool") then return it end
    end
    return nil
end

local function f2_getBestRod()
    if selectedRodToBuy then
        local found = f2_findItem(selectedRodToBuy)
        if found then return found, ROD_TIERS[selectedRodToBuy] or 2 end
    end
    local best, bestTier = nil, 0
    local function check(tool)
        local tier = ROD_TIERS[tool.Name]
        if tier and tier > bestTier then bestTier = tier; best = tool end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then for _, t in ipairs(bp:GetChildren()) do check(t) end end
    local ch = LocalPlayer.Character or char
    if ch then for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") then check(t) end end end
    return best, bestTier
end

local function f2_getBait()
    if selectedRodToBuy then
        local prefBait = ROD_BAIT[selectedRodToBuy]
        if prefBait then
            local found = f2_findItem(prefBait)
            if found then
                local tier = (found.Name == "WormtecUltimate" and 3) or (found.Name == "WormtecPro" and 2) or 1
                return found, tier
            end
        end
    end
    local best, bestTier = nil, 0
    local function check(tool)
        if tool and tool:IsA("Tool") and BAIT_NAMES[tool.Name] then
            local tier = (tool.Name == "WormtecUltimate" and 3) or (tool.Name == "WormtecPro" and 2) or 1
            if tier > bestTier then bestTier = tier; best = tool end
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then for _, t in ipairs(bp:GetChildren()) do check(t) end end
    local ch = LocalPlayer.Character or char
    if ch then for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") then check(t) end end end
    return best, bestTier
end

local function findCastButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local b = pg:FindFirstChild("FishingCastButton", true)
    if b then return b end
    local gui = pg:FindFirstChild("MD_HouseRentalGui")
    return gui and gui:FindFirstChild("FishingCastButton", true)
end

local function ensureBaitLoaded(rod, bait)
    if not rod or not bait then return end
    local curAmmo = nil
    for _, attr in ipairs({"MD_Ammo", "Ammo", "Bait", "BaitCount", "MD_Bait"}) do
        local val = rod:GetAttribute(attr)
        if typeof(val) == "number" then
            curAmmo = val
            break
        end
    end
    if curAmmo == nil then
        for _, ch in ipairs(rod:GetChildren()) do
            if ch:IsA("NumberValue") or ch:IsA("IntValue") then
                local n = ch.Name:lower()
                if n:find("ammo") or n:find("bait") or n:find("count") then
                    curAmmo = ch.Value
                    break
                end
            end
        end
    end
    if curAmmo == nil or curAmmo <= 0 then
        local houseR = ReplicatedStorage:FindFirstChild("MD_HouseRentalRemote")
        if houseR then
            pcall(function() houseR:FireServer("EquipFishingBait", bait) end)
            pcall(function() houseR:FireServer("EquipFishingBait", bait.Name) end)
        end
        local itemsEv = ReplicatedStorage:FindFirstChild("MD_ItemsEvent")
        if itemsEv then
            pcall(function() itemsEv:FireServer("EquipBait", bait) end)
            pcall(function() itemsEv:FireServer("EquipFishingBait", bait) end)
        end
        task.wait(0.3)
    end
end

local function fish2Setup()
    local houseR = ReplicatedStorage:FindFirstChild("MD_HouseRentalRemote")
    if not houseR then return false end

    local rodToBuy = selectedRodToBuy or "FishingRodPro"
    local expectedBait = ROD_BAIT[rodToBuy] or "WormtecRegular"
    local rodTool = f2_findItem(rodToBuy)
    local baitTool = f2_findItem(expectedBait)
    local needRod = (rodTool == nil)
    local needBait = (baitTool == nil)

    if not needRod and not needBait then
        pcall(function() hum:EquipTool(rodTool) end)
        task.wait(0.3)
        ensureBaitLoaded(rodTool, baitTool)
        return true
    end

    local cash = getPlayerCash()

    if needRod then
        local reqBudget = ROD_BUDGETS[rodToBuy] or 2050
        if cash < reqBudget then
            turnOffAutoFish("Dinero insuficiente! Tienes $" .. cash .. " y necesitas $" .. reqBudget .. " para " .. (ROD_DISPLAY_NAMES[rodToBuy] or rodToBuy) .. ".")
            return false
        end
    elseif needBait then
        local baitCost = BAIT_PRICES[expectedBait] or 200
        if cash < baitCost then
            turnOffAutoFish("Dinero insuficiente! Tienes $" .. cash .. " y necesitas $" .. baitCost .. " para la carnada (" .. expectedBait .. ").")
            return false
        end
    end

    if not fish2Move(COORD_FISH_SHOP) then
        return false
    end
    task.wait(1.5)
    if not fish2Active then return false end

    pcall(function() houseR:FireServer("OpenFishing") end)
    task.wait(1.0)

    if needRod then
        pcall(function() houseR:FireServer("BuyFishing", rodToBuy) end)
        local waited = 0
        while not f2_findItem(rodToBuy) and waited < 6 do
            task.wait(0.4)
            waited += 0.4
        end
        if not f2_findItem(rodToBuy) then
            task.wait(1.0)
            pcall(function() houseR:FireServer("BuyFishing", rodToBuy) end)
            task.wait(1.5)
        end
        rodTool = f2_findItem(rodToBuy)
    end

    if needBait then
        task.wait(0.5)
        pcall(function() houseR:FireServer("BuyFishing", expectedBait, BAIT_BUY_QTY) end)
        local waited = 0
        while not f2_findItem(expectedBait) and waited < 6 do
            task.wait(0.4)
            waited += 0.4
        end
        baitTool = f2_findItem(expectedBait)
    end

    local finalRod = rodTool or f2_getBestRod()
    local finalBait = baitTool or f2_getBait()
    if not finalRod or not finalBait then return false end

    pcall(function() hum:EquipTool(finalRod) end)
    task.wait(0.3)
    ensureBaitLoaded(finalRod, finalBait)
    return true
end

local function baitRestock()
    local houseR = ReplicatedStorage:FindFirstChild("MD_HouseRentalRemote")
    if not houseR then return false end

    local rod = f2_getBestRod()
    if not rod then
        if not fish2Setup() then return false end
        rod = f2_getBestRod()
        if not rod then return false end
    end

    local baitToBuy = ROD_BAIT[rod.Name] or "WormtecRegular"
    local baitCost = BAIT_PRICES[baitToBuy] or 200
    local cash = getPlayerCash()
    if cash < baitCost then
        turnOffAutoFish("Dinero insuficiente para recargar carnada! Tienes $" .. cash .. " y necesitas $" .. baitCost .. ".")
        return false
    end

    if not fish2Move(COORD_FISH_SHOP) then return false end
    task.wait(1.5)
    if not fish2Active then return false end

    pcall(function() houseR:FireServer("OpenFishing") end)
    task.wait(1.0)
    pcall(function() houseR:FireServer("BuyFishing", baitToBuy, BAIT_BUY_QTY) end)

    local waited = 0
    while not f2_findItem(baitToBuy) and waited < 6 do
        task.wait(0.4)
        waited += 0.4
    end

    local bait = f2_findItem(baitToBuy) or f2_getBait()
    if bait then
        pcall(function() hum:EquipTool(rod) end)
        task.wait(0.3)
        ensureBaitLoaded(rod, bait)
        return true
    end
    return false
end

local KNOWN_FISH = {
    ["salmon"] = true,
    ["bass"] = true,
    ["tuna"] = true,
    ["perch"] = true,
    ["marlin"] = true,
    ["shark"] = true,
    ["sailfish"] = true,
    ["anglerfish"] = true,
    ["pufferfish"] = true,
    ["oarfish"] = true,
    ["coelacanth"] = true,
    ["dolphinfish"] = true,
    ["northern pike"] = true,
}

local function isToolAFish(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local nm = tool.Name:lower()
    if nm:find("rod") or nm:find("cana") or nm:find("bait") or nm:find("carnada") or nm:find("prawntec") or nm:find("wormtec") then
        return false
    end
    if tool:GetAttribute("MD_FarmKind") == "fish"
    or tool:GetAttribute("FishingItem") == "fish"
    or tool:GetAttribute("MD_FishWeight") ~= nil
    or tool:GetAttribute("MaxFresh") ~= nil
    or tool:GetAttribute("MinFresh") ~= nil then
        return true
    end
    for k in pairs(KNOWN_FISH) do
        if nm:find(k) then return true end
    end
    return false
end

local function countToolFish()
    local total = 0
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    local ch = LocalPlayer.Character or char
    for _, container in ipairs({bp, ch}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if isToolAFish(item) then
                    total += (tonumber(item:GetAttribute("MD_StackCount")) or 1)
                end
            end
        end
    end
    return total
end

local function getFishOwnedFromGui()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local gui = pg and pg:FindFirstChild("MD_FishSellGui")
    local panel = gui and gui:FindFirstChild("FishSellPanel", true)
    if panel and panel.Visible then
        local status = panel:FindFirstChild("Status")
        if status and status:IsA("TextLabel") and status.Text then
            local num = status.Text:match("Fish owned:%s*(%d+)")
            if num then return tonumber(num) or 0 end
        end
        local list = panel:FindFirstChild("FishList")
        if list then
            local c = 0
            for _, ch in ipairs(list:GetChildren()) do
                if ch:IsA("Frame") and ch.Name:find("Fish_") then c += 1 end
            end
            if c > 0 then return c end
        end
    end
    return 0
end

local function getFishCount()
    local inBag = countToolFish()
    local fromGui = getFishOwnedFromGui()
    return math.max(inBag, fromGui)
end

local function sellFishRoutine()
    if not fish2Active or isSellingFish then return false end
    isSellingFish = true

    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
    if hrp and hrp.Parent then hrp.Anchored = false end
    task.wait(0.15)

    local wp1Ok = false
    for wp1Try = 1, 10 do
        if not fish2Active then break end
        fish2Move(COORD_SELL_WP1)
        if fish2HoldPosition(COORD_SELL_WP1, 2.0) then
            wp1Ok = true
            break
        end
        task.wait(0.2)
    end
    if not wp1Ok and fish2Active then
        fish2Move(COORD_SELL_WP1)
        fish2HoldPosition(COORD_SELL_WP1, 2.0)
    end

    task.wait(0.1)

    local wp2Ok = false
    for wp2Try = 1, 10 do
        if not fish2Active then break end
        fish2Move(COORD_SELL_WP2)
        if fish2HoldPosition(COORD_SELL_WP2, 2.0) then
            wp2Ok = true
            break
        end
        task.wait(0.2)
    end
    if not wp2Ok and fish2Active then
        fish2Move(COORD_SELL_WP2)
        fish2HoldPosition(COORD_SELL_WP2, 2.0)
    end

    local beacon = workspace:FindFirstChild("SellFishBeacon", true)
    local touchPart = (beacon and beacon:FindFirstChild("TouchPart"))
    if not touchPart then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "TouchPart" and (obj.Position - COORD_SELL_WP2).Magnitude < 15 then
                touchPart = obj; break
            end
        end
    end

    local function triggerBeaconTouch()
        if touchPart and hrp and hrp.Parent then
            pcall(function() hrp.CFrame = CFrame.new(touchPart.Position + Vector3.new(0, 1.2, 0)) end)
            if typeof(firetouchinterest) == "function" then
                pcall(function()
                    firetouchinterest(hrp, touchPart, 0)
                    task.wait(0.08)
                    firetouchinterest(hrp, touchPart, 1)
                end)
            end
        else
            pcall(function() hrp.CFrame = CFrame.new(COORD_SELL_WP2) end)
        end
    end

    local fishRemote = ReplicatedStorage:FindFirstChild("MD_FishingRemote")
    local startCash = tonumber(LocalPlayer:GetAttribute("Cash")) or 0
    local sellConfirmed = false
    lastSellConfirmed = false

    for attempt = 1, 8 do
        if not fish2Active then break end

        local distSeller = (hrp.Position - COORD_SELL_WP2).Magnitude
        if distSeller > 4.5 then
            fish2Move(COORD_SELL_WP2)
            fish2HoldPosition(COORD_SELL_WP2, 1.0)
        end

        triggerBeaconTouch()
        task.wait(0.15)

        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local gui = pg and pg:FindFirstChild("MD_FishSellGui")
        local panel = gui and gui:FindFirstChild("FishSellPanel", true)
        local sellAllBtn = panel and panel:FindFirstChild("SellAll")

        if sellAllBtn then
            pcall(function()
                if typeof(firesignal) == "function" and sellAllBtn.Activated then
                    firesignal(sellAllBtn.Activated)
                end
            end)
        end

        if fishRemote then
            pcall(function() fishRemote:FireServer("SellAll") end)
        end

        local checkStart = tick()
        while tick() - checkStart < 1.0 do
            task.wait(0.1)
            local curCash = tonumber(LocalPlayer:GetAttribute("Cash")) or 0
            local remainingFish = getFishCount()
            if lastSellConfirmed or (curCash > startCash) or (remainingFish == 0) then
                sellConfirmed = true
                break
            end
        end

        if sellConfirmed then break end
        task.wait(0.25)
    end

    lastSellConfirmed = false

    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local gui = pg and pg:FindFirstChild("MD_FishSellGui")
    local panel = gui and gui:FindFirstChild("FishSellPanel", true)
    if panel then
        local closeBtn = panel:FindFirstChild("Close")
        if closeBtn and typeof(firesignal) == "function" and closeBtn.Activated then
            pcall(function() firesignal(closeBtn.Activated) end)
        end
        panel.Visible = false
    end

    task.wait(0.5)

    local returnCFrame = FISH_ZONES[fish2Zone] or FISH_ZONES["Nivel 0"]

    local standPart = workspace:FindFirstChild("MD_FishStand_Safe")
    if not standPart then
        standPart = Instance.new("Part")
        standPart.Name = "MD_FishStand_Safe"
        standPart.Size = Vector3.new(15, 2, 15)
        standPart.Anchored = true
        standPart.CanCollide = true
        standPart.Transparency = 1
        standPart.Parent = workspace
    end
    standPart.CFrame = CFrame.new(returnCFrame.Position - Vector3.new(0, 3.1, 0))

    fish2Move(returnCFrame)

    hrp.CFrame = returnCFrame
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.Anchored = true

    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end) end
    fishHoldConn = RunService.Heartbeat:Connect(function()
        if not fish2Active or not hrp or not hrp.Parent then return end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if not hrp.Anchored then hrp.Anchored = true end
    end)

    local curRod = f2_getBestRod()
    local curBait = f2_getBait()
    if curRod and curBait then
        ensureBaitLoaded(curRod, curBait)
    end

    lastSellTimestamp = os.clock()
    isSellingFish = false
    return true
end

local function fishLoop()
    if not fish2Setup() then
        fish2Active = false
        return
    end

    local targetCFrame = FISH_ZONES[fish2Zone] or FISH_ZONES["Nivel 0"]

    local stand = workspace:FindFirstChild("MD_FishStand_Safe")
    if not stand then
        stand = Instance.new("Part")
        stand.Name = "MD_FishStand_Safe"
        stand.Size = Vector3.new(15, 2, 15)
        stand.Anchored = true
        stand.CanCollide = true
        stand.Transparency = 1
        stand.Parent = workspace
    end
    stand.CFrame = CFrame.new(targetCFrame.Position - Vector3.new(0, 3.1, 0))

    if not fish2Move(targetCFrame) then
        fish2Active = false
        return
    end

    hrp.CFrame = targetCFrame
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.Anchored = true

    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end) end
    fishHoldConn = RunService.Heartbeat:Connect(function()
        if not fish2Active or not hrp or not hrp.Parent then return end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if not hrp.Anchored then hrp.Anchored = true end
    end)

    local rod = f2_getBestRod()
    local bait = f2_getBait()
    if rod then pcall(function() hum:EquipTool(rod) end) end
    task.wait(0.3)
    if rod and bait then
        ensureBaitLoaded(rod, bait)
    end
    task.wait(0.3)

    local fishRemote = ReplicatedStorage:FindFirstChild("MD_FishingRemote")
    if not fishRemote then
        hrp.Anchored = false
        fish2Active = false
        return
    end

    local castAccepted = false
    local castInProgress = false
    local needsBaitRestock = false
    local endSeq = 0
    local lastOutcome = "none"

    if fishEventConn then pcall(function() fishEventConn:Disconnect() end); fishEventConn = nil end
    fishEventConn = fishRemote.OnClientEvent:Connect(function(action, data)
        if not fish2Active then return end

        if action == "Wait" or action == "Cast" then
            castAccepted = true
        elseif action == "Bite" and type(data) == "table" then
            castAccepted = true
            local round = tonumber(data.round) or 1
            local center = math.clamp(tonumber(data.center) or 0.5, 0, 1)
            local period = tonumber(data.period) or 1.65
            if period <= 0 then period = 1.65 end
            local startTime = tonumber(data.start) or workspace:GetServerTimeNow()

            local now = workspace:GetServerTimeNow()
            local cycle = math.max(0, math.floor((now - startTime) / period))
            local targetHit = startTime + (cycle + center) * period
            if targetHit < now + 0.04 then
                targetHit = targetHit + period
            end

            local delayTime = math.clamp(targetHit - now, 0.04, period + 0.1)
            task.delay(delayTime, function()
                if not fish2Active then return end
                local atTime = workspace:GetServerTimeNow()
                pcall(function()
                    fishRemote:FireServer("Reel", {
                        round = round,
                        at = atTime
                    })
                end)
            end)

        elseif action == "SellResult" then
            lastSellConfirmed = true
        elseif action == "End" then
            endSeq += 1
            castAccepted = false
            castInProgress = false

            local isCatch = false
            if type(data) == "string" then
                local msg = data:lower()
                if msg:find("caught") or msg:find("atrapado") or msg:find("capturado") or msg:find("pesca") or msg:find("fish") then
                    isCatch = true
                end
            elseif type(data) == "table" then
                if data.success == true or data.caught == true or data.fish ~= nil or data.item ~= nil then
                    isCatch = true
                else
                    for _, v in pairs(data) do
                        if type(v) == "string" then
                            local msg = v:lower()
                            if msg:find("caught") or msg:find("atrapado") or msg:find("capturado") then
                                isCatch = true
                                break
                            end
                        end
                    end
                end
            end

            if isCatch then
                lastOutcome = "caught"
            elseif type(data) == "string" and (data:lower():find("buy bait") or data:lower():find("out of bait") or data:lower():find("no bait") or data:lower():find("carnada")) then
                needsBaitRestock = true
                lastOutcome = "nobait"
            else
                lastOutcome = "other"
            end

        elseif action == "Cancel" then
            endSeq += 1
            castAccepted = false
            castInProgress = false
            lastOutcome = "cancel"
        end
    end)

    local function doCastOnce(curRod, curBait, targetCFrameParam)
        if not fish2Active or castInProgress then return false end

        local btn = findCastButton()
        if btn and btn.Text ~= "CAST" then
            if btn.Text == "CANCEL" or btn.Text:find("CANCEL") then
                pcall(function() fishRemote:FireServer("Cancel") end)
                task.wait(0.3)
            end
            local w = 0
            while btn and btn.Text ~= "CAST" and w < 3 and fish2Active do
                task.wait(0.2)
                w += 0.2
            end
            if btn and btn.Text ~= "CAST" then
                pcall(function() fishRemote:FireServer("Cancel") end)
                task.wait(0.2)
            end
        end

        if curRod and char and not char:FindFirstChild(curRod.Name) then
            pcall(function() hum:EquipTool(curRod) end)
            task.wait(0.2)
        end

        ensureBaitLoaded(curRod, curBait)

        local preSeq = endSeq
        castAccepted = false
        castInProgress = true

        local castTarget = targetCFrameParam.Position + (targetCFrameParam.LookVector * 20)
        pcall(function()
            fishRemote:FireServer("Cast", castTarget)
        end)

        local deadline = os.clock() + 10
        while fish2Active and not castAccepted and endSeq == preSeq and os.clock() < deadline do
            task.wait(0.1)
        end

        if castAccepted and endSeq == preSeq then
            local biteWaitStart = os.clock()
            while fish2Active and endSeq == preSeq and (os.clock() - biteWaitStart < 30) do
                task.wait(0.15)
            end
        end

        castInProgress = false
        castAccepted = false
        return (endSeq ~= preSeq)
    end

    while fish2Active do
        while isSafeHealing and fish2Active do
            task.wait(0.25)
        end
        if antiSkidsActive and not isSafeHealing and hum and hum.Health < 80 and hum.Health > 0 then
            safeHealRoutine()
        end
        local desiredCFrame = FISH_ZONES[fish2Zone] or FISH_ZONES["Nivel 0"]
        if (targetCFrame.Position - desiredCFrame.Position).Magnitude > 1 then
            targetCFrame = desiredCFrame
            if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
            if hrp and hrp.Parent then hrp.Anchored = false end
            task.wait(0.1)

            local standPart = workspace:FindFirstChild("MD_FishStand_Safe")
            if standPart then
                standPart.CFrame = CFrame.new(targetCFrame.Position - Vector3.new(0, 3.1, 0))
            end

            if not fish2Move(targetCFrame) then break end

            hrp.CFrame = targetCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.Anchored = true

            if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end) end
            fishHoldConn = RunService.Heartbeat:Connect(function()
                if not fish2Active or not hrp or not hrp.Parent then return end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                if not hrp.Anchored then hrp.Anchored = true end
            end)

            task.wait(0.5)
        end

        local currentFish = getFishCount()
        if currentFish >= MAX_FISH_CAPACITY and not isSellingFish and (os.clock() - lastSellTimestamp > 3) then
            sellFishRoutine()
            if not fish2Active then break end
            lastOutcome = "none"
            task.wait(0.5)
        end

        if needsBaitRestock or f2_getBait() == nil then
            needsBaitRestock = false
            castAccepted = false
            castInProgress = false

            if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
            if hrp and hrp.Parent then hrp.Anchored = false end
            task.wait(0.2)

            local restockOk = baitRestock()
            if not restockOk or not f2_getBait() then
                break
            end

            local standPart = workspace:FindFirstChild("MD_FishStand_Safe")
            if standPart then
                standPart.CFrame = CFrame.new(targetCFrame.Position - Vector3.new(0, 3.1, 0))
            end

            if not fish2Move(targetCFrame) then break end

            hrp.CFrame = targetCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.Anchored = true

            if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end) end
            fishHoldConn = RunService.Heartbeat:Connect(function()
                if not fish2Active or not hrp or not hrp.Parent then return end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                if not hrp.Anchored then hrp.Anchored = true end
            end)

            local curRod = f2_getBestRod()
            local curBait = f2_getBait()
            if curRod and curBait then
                ensureBaitLoaded(curRod, curBait)
            end

            lastOutcome = "none"
            task.wait(1.5)
        end

        currentFish = getFishCount()
        if not castInProgress and currentFish < MAX_FISH_CAPACITY then
            local waitDelay = (lastOutcome == "caught") and 0.8 or 2.5
            task.wait(waitDelay)

            currentFish = getFishCount()
            if fish2Active and not castInProgress and not isSellingFish and not needsBaitRestock and currentFish < MAX_FISH_CAPACITY then
                local currentRod = f2_getBestRod()
                local currentBait = f2_getBait()
                if currentRod and currentBait then
                    doCastOnce(currentRod, currentBait, targetCFrame)
                end
            end
        end

        task.wait(0.5)
    end

    if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
    if fishEventConn then pcall(function() fishEventConn:Disconnect() end); fishEventConn = nil end
    if hrp and hrp.Parent then hrp.Anchored = false end
    local standEnd = workspace:FindFirstChild("MD_FishStand_Safe")
    if standEnd then pcall(function() standEnd:Destroy() end) end
    fish2Active = false
end

Tabs.Farm2:Section({ Title = "FISH | Auto Farm", Icon = "solar:water-bold", Opened = true })
Tabs.Farm2:Space()
Tabs.Farm2:Dropdown({
    Title   = "Zona de Pesca",
    Desc    = "Coordenadas donde farmeara",
    Icon    = "solar:map-point-bold",
    Values  = { "Nivel 0", "Nivel 10", "Nivel 20", "Nivel 25", "Nivel 60" },
    Value   = "Nivel 0",
    Callback = function(v)
        if fish2Zone == v then return end
        fish2Zone = v
        if fish2Active then
            pcall(function()
                local fishRemote = ReplicatedStorage:FindFirstChild("MD_FishingRemote")
                if fishRemote then fishRemote:FireServer("Cancel") end
            end)
            if fish2Thread then
                task.cancel(fish2Thread)
                fish2Thread = nil
            end
            killFishMove()
            if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
            if fishEventConn then pcall(function() fishEventConn:Disconnect() end); fishEventConn = nil end
            if hrp and hrp.Parent then hrp.Anchored = false end
            fish2Thread = task.spawn(fishLoop)
        end
    end
})
Tabs.Farm2:Slider({
    Title   = "Limite de peces",
    Desc    = "Cantidad de peces para ir a vender",
    Icon    = "solar:box-bold",
    Step    = 1,
    Value   = { Min = 1, Max = 20, Default = 15 },
    Callback = function(v)
        MAX_FISH_CAPACITY = v
        if fish2Active and not isSellingFish and getFishCount() >= MAX_FISH_CAPACITY then
            task.defer(function()
                if fish2Active and not isSellingFish and getFishCount() >= MAX_FISH_CAPACITY then
                    sellFishRoutine()
                end
            end)
        end
    end
})
Tabs.Farm2:Dropdown({
    Title    = "Velocidad de movimiento",
    Desc     = "Velocidad de desplazamiento",
    Icon     = "solar:running-bold",
    Values   = { "Nivel 1", "Nivel 2" },
    Value    = "Nivel 1",
    Callback = function(v)
        F2_SPEED = F2_SPEED_LEVELS[v] or 20
    end
})
Tabs.Farm2:Dropdown({
    Title    = "Cana de Pescar",
    Desc     = "Cana que comprara y usara para pescar",
    Icon     = "solar:shop-bold",
    Values   = { "Fishing Rod Regular", "Fishing Rod Pro", "Fishing Rod Advanced", "Fishing Rod Ultimate" },
    Value    = "Fishing Rod Pro",
    Callback = function(v)
        local map = {
            ["Fishing Rod Regular"]  = "FishingRodRegular",
            ["Fishing Rod Pro"]      = "FishingRodPro",
            ["Fishing Rod Advanced"] = "FishingRodAdvanced",
            ["Fishing Rod Ultimate"] = "FishingRodUltimate",
        }
        selectedRodToBuy = map[v] or "FishingRodPro"
    end
})
autoFishToggle = Tabs.Farm2:Toggle({
    Title    = "Auto Pesca",
    Desc     = "Prepara equipo, viaja a la zona y pesca anclado",
    Icon     = "solar:fishing-bold",
    Value    = false,
    Callback = function(state)
        if state then
            if fish2Active then return end
            if hrp and hrp.Parent then
                fishSavedOrigin = hrp.CFrame
            end
            fish2Active = true
            fish2Thread = task.spawn(fishLoop)
        else
            fish2Active = false
            if fish2Thread then task.cancel(fish2Thread); fish2Thread = nil end
            killFishMove()
            if fishHoldConn then pcall(function() fishHoldConn:Disconnect() end); fishHoldConn = nil end
            if fishEventConn then pcall(function() fishEventConn:Disconnect() end); fishEventConn = nil end
            if hrp and hrp.Parent then hrp.Anchored = false end
            local standEnd = workspace:FindFirstChild("MD_FishStand_Safe")
            if standEnd then pcall(function() standEnd:Destroy() end) end

            if fishSavedOrigin and hrp and hrp.Parent then
                local origPos = fishSavedOrigin.Position
                local startPos = hrp.Position
                local dist = (startPos - origPos).Magnitude
                if dist > 3 then
                    local underStart  = Vector3.new(startPos.X,  startPos.Y  - 10, startPos.Z)
                    local underTarget = Vector3.new(origPos.X,   origPos.Y   - 10, origPos.Z)
                    local duration = math.clamp(dist / (F2_SPEED * 4), 0.1, 4)
                    local elapsed = 0
                    local retConn
                    retConn = RunService.Heartbeat:Connect(function(dt)
                        if not hrp or not hrp.Parent then
                            pcall(function() retConn:Disconnect() end)
                            return
                        end
                        elapsed += dt
                        local t = math.min(elapsed / duration, 1)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.CFrame = CFrame.new(underStart:Lerp(underTarget, t))
                        if t >= 1 then
                            pcall(function() retConn:Disconnect() end)
                            hrp.CFrame = fishSavedOrigin
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                else
                    hrp.CFrame = fishSavedOrigin
                end
            end
        end
    end
})

local Camera = workspace.CurrentCamera

_G.Silent_Enabled         = false
_G.Silent_Range           = 350
_G.Silent_FOV             = 130
_G.Silent_ShowFOV         = false
_G.Silent_TeamCheck       = false
_G.Silent_Priority        = "Head"
_G.Silent_PredictEnabled  = false
_G.Silent_PredictStrength = 5

local CurrentTargetPart = nil
local WeaponEquipped    = false

local FOVCircleSilent = Drawing.new("Circle")
FOVCircleSilent.Thickness    = 1.5
FOVCircleSilent.Color        = Color3.fromRGB(0, 255, 200)
FOVCircleSilent.Transparency = 0.8
FOVCircleSilent.Filled       = false
FOVCircleSilent.Visible      = false

local function checkWeapon()
    local c = LocalPlayer.Character
    if not c then 
        WeaponEquipped = false
        return 
    end
    local tool = c:FindFirstChildWhichIsA("Tool")
    WeaponEquipped = (tool ~= nil)
end

local function resolveBestPart(targetChar)
    if not targetChar then return nil end

    local head  = targetChar:FindFirstChild("Head")
    local root  = targetChar:FindFirstChild("HumanoidRootPart")
    local torso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or root

    if _G.Silent_Priority == "Torso" then
        return torso or head
    end

    return head or torso
end

-- Predicción: posición futura = posición actual + velocidad * (ping + tiempo de vuelo de bala)
local function getPredictedPosition(targetPart, origin)
    local currentPos = targetPart.Position

    if not _G.Silent_PredictEnabled or _G.Silent_PredictStrength <= 0 then
        return currentPos
    end

    local ok, result = pcall(function()
        local velocity = targetPart.AssemblyLinearVelocity or Vector3.zero

        -- Ping en segundos (GetNetworkPing devuelve RTT/2)
        local ping = 0
        pcall(function() ping = LocalPlayer:GetNetworkPing() end)
        if typeof(ping) ~= "number" or ping ~= ping or ping < 0 then ping = 0 end
        ping = math.clamp(ping, 0, 1)

        -- Tiempo estimado de vuelo de la bala (asume ~800 studs/s, ajustable con el slider)
        local distance   = (currentPos - origin).Magnitude
        local travelTime = distance / 800

        -- El slider 1-20 escala el lead: 10 = 1x exacto, 20 = 2x agresivo
        local strength   = _G.Silent_PredictStrength / 10
        local predictTime = (travelTime + ping) * strength

        local predicted = currentPos + (velocity * predictTime)

        -- Guard contra NaN / Inf (causa de balas invisibles)
        if predicted.X ~= predicted.X or predicted.Y ~= predicted.Y or predicted.Z ~= predicted.Z then
            return currentPos
        end
        if predicted.Magnitude > 100000 then
            return currentPos
        end

        return predicted
    end)

    if ok and typeof(result) == "Vector3" then
        return result
    end
    return currentPos
end

local function getClosestTargetBy3D()
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos        = c.HumanoidRootPart.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local bestPart      = nil
    local minDistance3D = math.huge

    local playerPool = _G.GetRealPlayers and _G.GetRealPlayers() or Players:GetPlayers()

    for _, pl in ipairs(playerPool) do
        if pl ~= LocalPlayer and pl.Character then
            local hum        = pl.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = resolveBestPart(pl.Character)

            if targetPart and hum and hum.Health > 0 then
                local isTeam = _G.Silent_TeamCheck and LocalPlayer.Team and pl.Team and (pl.Team == LocalPlayer.Team)
                if not isTeam then
                    local dist3D = (myPos - targetPart.Position).Magnitude

                    if dist3D <= _G.Silent_Range then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                        if onScreen then
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if screenDist <= _G.Silent_FOV then
                                if dist3D < minDistance3D then
                                    minDistance3D = dist3D
                                    bestPart      = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPart
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}

    if _G.Silent_Enabled and WeaponEquipped and not checkcaller() and CurrentTargetPart then
        if method == "FireServer" then
            local remoteName = self.Name

            if remoteName == "GlockEvent" and args[1] == "Shoot" and type(args[2]) == "table" then
                local data   = args[2]
                local origin = data.origin or Camera.CFrame.Position
                local aimPos = getPredictedPosition(CurrentTargetPart, origin)
                local dir    = aimPos - origin
                -- Solo toca el paquete si el vector es válido, si no pasa intacto
                if dir.Magnitude > 0.01 then
                    data.direction = dir.Unit
                    return oldNamecall(self, "Shoot", data)
                end
            end

            if remoteName == "MD_ItemsEvent" and args[1] == "FireGun" and type(args[2]) == "table" then
                local data   = args[2]
                local origin = data.origin or Camera.CFrame.Position
                local aimPos = getPredictedPosition(CurrentTargetPart, origin)
                local dir    = aimPos - origin
                if dir.Magnitude > 0.01 then
                    data.direction = dir.Unit
                    return oldNamecall(self, "FireGun", data)
                end
            end
        end

        if self == Camera and (method == "ViewportPointToRay" or method == "ScreenPointToRay") then
            local origin = Camera.CFrame.Position
            local aimPos = getPredictedPosition(CurrentTargetPart, origin)
            local dir    = aimPos - origin
            if dir.Magnitude > 0.01 then
                return Ray.new(origin, dir.Unit)
            end
        end
    end

    return oldNamecall(self, ...)
end))

RunService.RenderStepped:Connect(function()
    checkWeapon()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if _G.Silent_Enabled and WeaponEquipped then
        CurrentTargetPart = getClosestTargetBy3D()
    else
        CurrentTargetPart = nil
    end

    FOVCircleSilent.Position = center
    FOVCircleSilent.Radius   = _G.Silent_FOV
    FOVCircleSilent.Visible  = _G.Silent_Enabled and _G.Silent_ShowFOV
end)

Tabs.Combat:Section({ Title = "COMBAT | Silent Aim", Icon = "solar:target-bold", Opened = true })
Tabs.Combat:Space()

Tabs.Combat:Toggle({
    Title    = "Silent Aim",
    Desc     = "Redirige las balas directamente al objetivo sin tiros fantasma",
    Icon     = "solar:target-bold",
    Value    = false,
    Callback = function(state)
        _G.Silent_Enabled = state
        if not state then
            CurrentTargetPart       = nil
            FOVCircleSilent.Visible = false
        else
            FOVCircleSilent.Visible = _G.Silent_ShowFOV
        end
    end
})

Tabs.Combat:Toggle({
    Title    = "Predicción",
    Desc     = "Apunta a donde estará el objetivo (velocidad + ping). Actívalo si falla mucho",
    Icon     = "solar:radar-2-bold",
    Value    = false,
    Callback = function(state)
        _G.Silent_PredictEnabled = state
    end
})

Tabs.Combat:Slider({
    Title    = "Fuerza de Predicción",
    Desc     = "1-20. Sube si el objetivo se mueve rápido y aún falla. Baja si te pasas de largo",
    Icon     = "solar:tuning-2-bold",
    Step     = 1,
    Value    = { Min = 1, Max = 20, Default = 5 },
    Callback = function(v)
        _G.Silent_PredictStrength = v
    end
})

Tabs.Combat:Slider({
    Title    = "Radio FOV",
    Desc     = "Tamaño del área central de captura",
    Icon     = "solar:maximize-square-minimalistic-bold",
    Step     = 1,
    Value    = { Min = 1, Max = 360, Default = 130 },
    Callback = function(v)
        _G.Silent_FOV = v
        FOVCircleSilent.Radius = v
    end
})

Tabs.Combat:Slider({
    Title    = "Rango de Distancia",
    Desc     = "Distancia máxima en studs para detectar enemigos",
    Icon     = "solar:radar-2-bold",
    Step     = 25,
    Value    = { Min = 1, Max = 3500, Default = 350 },
    Callback = function(v)
        _G.Silent_Range = v
    end
})

Tabs.Combat:Toggle({
    Title    = "Team Check",
    Desc     = "Ignora a jugadores de tu mismo equipo",
    Icon     = "solar:shield-check-bold",
    Value    = false,
    Callback = function(state)
        _G.Silent_TeamCheck = state
        CurrentTargetPart   = nil
    end
})

Tabs.Combat:Toggle({
    Title    = "Mostrar FOV",
    Desc     = "Muestra u oculta el círculo guía central",
    Icon     = "solar:eye-bold",
    Value    = false,
    Callback = function(state)
        _G.Silent_ShowFOV = state
        FOVCircleSilent.Visible = _G.Silent_Enabled and state
    end
})

Tabs.Combat:Dropdown({
    Title    = "Seleccionar Parte",
    Desc     = "Parte del cuerpo a impactar",
    Icon     = "solar:user-bold",
    Values   = { "Head", "Torso" },
    Value    = "Head",
    Callback = function(option)
        _G.Silent_Priority = option
    end
})
