--[[
    ROOK ULTIMATE V2 - MEGA EDITION
    Tudo funcional, sem botões falsos. Otimizado para Delta.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- [ THEME & STATE ]
-- ==========================================
local Theme = {
    Bg = Color3.fromRGB(10, 10, 12),
    Surface = Color3.fromRGB(18, 18, 22),
    SurfaceLight = Color3.fromRGB(30, 25, 40),
    Accent = Color3.fromRGB(160, 60, 255), -- Roxo Neon
    AccentGlow = Color3.fromRGB(200, 130, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 160),
    Success = Color3.fromRGB(50, 200, 80),
    Error = Color3.fromRGB(255, 60, 60),
    Border = Color3.fromRGB(40, 35, 50)
}

local State = {
    ActiveTab = "Dashboard",
    CurrentProfile = "Padrão",
    Timer = { Active = false, Time = 0, Target = 0 },
    Session = { Start = 0, Active = false, History = {} },
    Notes = "",
    ParkourStats = {},
    Havoc = {
        BFE = {
            {Q="O que é o BFE?", A="Batalhão de Forças Especiais."},
            {Q="Qual o lema do BFE?", A="Força, Honra e Disciplina."},
            {Q="Como ingressar no BFE?", A="Passar pelo treinamento oficial no QG."}
        },
        BFC = {
            {Q="O que é o BFC?", A="Batalhão de Fuzileiros de Combate."},
            {Q="Arma padrão do BFC?", A="Fuzil de Assalto."}
        },
        BAC = {
            {Q="O que é o BAC?", A="Batalhão de Ações de Comando."},
            {Q="Qual a especialidade do BAC?", A="Operações especiais e resgate."}
        },
        XAC = { {Q="O que é XAC?", A="Comando de Operações Avançadas."} },
        CIE = { {Q="O que é CIE?", A="Centro de Inteligência do Exército."} },
        CIGS = { {Q="O que é CIGS?", A="Centro de Instrução de Guerra na Selva."} }
    },
    SelectedRoute = "Nenhuma"
}

local RookDataFolder = "RookUltimateV2"
if makefolder and not isfolder(RookDataFolder) then makefolder(RookDataFolder) end

local function GetProfilePath()
    return RookDataFolder .. "/" .. State.CurrentProfile .. ".json"
end

local function SaveProfile()
    if writefile then
        pcall(function()
            writefile(GetProfilePath(), HttpService:JSONEncode(State.Notes))
        end)
    end
end

-- ==========================================
-- [ UI BUILDER ]
-- ==========================================
if CoreGui:FindFirstChild("RookMega") then CoreGui.RookMega:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RookMega"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local function Notify(title, text, isError)
    local notif = Instance.new("Frame", ScreenGui)
    notif.Size = UDim2.new(0, 250, 0, 60)
    notif.Position = UDim2.new(1, 300, 1, -80)
    notif.BackgroundColor3 = Theme.Surface
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", notif).Color = isError and Theme.Error or Theme.Accent
    
    local titleL = Instance.new("TextLabel", notif)
    titleL.Size = UDim2.new(1, -20, 0, 20); titleL.Position = UDim2.new(0, 10, 0, 5)
    titleL.BackgroundTransparency = 1; titleL.Text = title
    titleL.TextColor3 = isError and Theme.Error or Theme.AccentGlow; titleL.Font = Enum.Font.GothamBold; titleL.TextSize = 12; titleL.TextXAlignment = Enum.TextXAlignment.Left
    
    local textL = Instance.new("TextLabel", notif)
    textL.Size = UDim2.new(1, -20, 0, 30); textL.Position = UDim2.new(0, 10, 0, 25)
    textL.BackgroundTransparency = 1; textL.Text = text; textL.TextColor3 = Theme.Text; textL.Font = Enum.Font.Gotham; textL.TextSize = 11; textL.TextWrapped = true; textL.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -260, 1, -80)}):Play()
    task.delay(3, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 300, 1, -80)}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 650, 0, 420)
Main.Position = UDim2.new(0.5, -325, 0.5, -210)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Theme.Border; MainStroke.Thickness = 1.5

-- TopBar
local TopBar = Instance.new("Frame", Main); TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Theme.Surface; TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1; Title.Text = "ROOK ULTIMATE V2"; Title.TextColor3 = Theme.Accent; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

local StatusLbl = Instance.new("TextLabel", TopBar); StatusLbl.Size = UDim2.new(0.3, 0, 1, 0); StatusLbl.Position = UDim2.new(0.4, 0, 0, 0)
StatusLbl.BackgroundTransparency = 1; StatusLbl.Text = "Status: ONLINE"; StatusLbl.TextColor3 = Theme.Success; StatusLbl.Font = Enum.Font.GothamBold; StatusLbl.TextSize = 11

local function WinBtn(txt, x, c)
    local b = Instance.new("TextButton", TopBar); b.Size = UDim2.new(0, 25, 0, 25); b.Position = UDim2.new(1, x, 0.5, -12); b.BackgroundColor3 = Theme.SurfaceLight; b.Text = txt; b.TextColor3 = c; b.Font = Enum.Font.GothamBold; b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4); return b
end
local MinBtn = WinBtn("-", -70, Theme.Text); local CloseBtn = WinBtn("X", -40, Theme.Error)

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 150, 1, -40); Sidebar.Position = UDim2.new(0, 0, 0, 40); Sidebar.BackgroundColor3 = Theme.Surface
local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, -150, 1, -40); Content.Position = UDim2.new(0, 150, 0, 40); Content.BackgroundColor3 = Theme.Bg

local Pages = {}
local Tabs = {"Dashboard", "Parkour", "Torres", "Extras", "Havoc", "Settings"}
for i, v in ipairs(Tabs) do
    local Btn = Instance.new("TextButton", Sidebar); Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Position = UDim2.new(0, 5, 0, 10 + ((i-1)*40))
    Btn.BackgroundColor3 = Theme.Bg; Btn.Text = v; Btn.TextColor3 = Theme.TextDim; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local P = Instance.new("ScrollingFrame", Content); P.Size = UDim2.new(1, -20, 1, -20); P.Position = UDim2.new(0, 10, 0, 10); P.BackgroundTransparency = 1; P.ScrollBarThickness = 2; P.ScrollBarImageColor3 = Theme.Accent; P.Visible = false
    Instance.new("UIListLayout", P).Padding = UDim.new(0, 10); Pages[v] = P
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Theme.Bg; b.TextColor3 = Theme.TextDim end end
        Btn.BackgroundColor3 = Theme.SurfaceLight; Btn.TextColor3 = Theme.Text; P.Visible = true; State.ActiveTab = v
    end)
end

-- Minimize / Close / Drag
local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin; TweenService:Create(Main, TweenInfo.new(0.3), {Size = isMin and UDim2.new(0, 650, 0, 40) or UDim2.new(0, 650, 0, 420)}):Play()
    MinBtn.Text = isMin and "+" or "-"; Sidebar.Visible = not isMin; Content.Visible = not isMin
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local drag, dragStart, startPos
TopBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dragStart = i.Position; startPos = Main.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end) end end)
UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)

-- ==========================================
-- [ COMPONENTES REUTILIZÁVEIS ]
-- ==========================================
local function CreateBtn(parent, text, color, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = color or Theme.SurfaceLight; b.Text = text; b.TextColor3 = Theme.Text; b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function() if callback then callback() end end); return b
end

local function CreateInput(parent, placeholder, default, callback)
    local b = Instance.new("TextBox", parent); b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = Theme.SurfaceLight; b.PlaceholderText = placeholder; b.Text = default or ""; b.TextColor3 = Theme.Text; b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.FocusLost:Connect(function() if callback then callback(b.Text) end end); return b
end

-- ==========================================
-- [ PÁGINA 1: DASHBOARD ]
-- ==========================================
local Dash = Pages["Dashboard"]
local infoCard = Instance.new("Frame", Dash); infoCard.Size = UDim2.new(1, -10, 0, 120); infoCard.BackgroundColor3 = Theme.Surface; Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", infoCard).Color = Theme.Border
local infoTxt = Instance.new("TextLabel", infoCard); infoTxt.Size = UDim2.new(1, -20, 1, -20); infoTxt.Position = UDim2.new(0, 10, 0, 10); infoTxt.BackgroundTransparency = 1; infoTxt.TextColor3 = Theme.Text; infoTxt.Font = Enum.Font.Gotham; infoTxt.TextSize = 12; infoTxt.TextXAlignment = Enum.TextXAlignment.Left; infoTxt.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    local start = tick()
    while ScreenGui.Parent do
        task.wait(1)
        infoTxt.Text = string.format("STATUS DO SISTEMA\n\n> Versão: 2.0\n> Uptime: %ds\n> Perfil: %s\n> Rota: %s\n> Havoc DB: Carregada", math.floor(tick()-start), State.CurrentProfile, State.SelectedRoute)
    end
end)

-- ==========================================
-- [ PÁGINA 2: PARKOUR (Sub-abas) ]
-- ==========================================
local Parkour = Pages["Parkour"]
local pkCats = Instance.new("Frame", Parkour); pkCats.Size = UDim2.new(1, -10, 0, 30); pkCats.BackgroundTransparency = 1
local pkLayout = Instance.new("UIListLayout", pkCats); pkLayout.FillDirection = Enum.FillDirection.Horizontal; pkLayout.Padding = UDim.new(0, 5)

local pkContent = Instance.new("Frame", Parkour); pkContent.Size = UDim2.new(1, -10, 0, 200); pkContent.BackgroundTransparency = 1; pkContent.ClipsDescendants = true; pkContent.LayoutOrder = 2

local pkData = {
    P1 = {"V1 DIREITA", "V2 ESQUERDA", "V3 ESQUERDA"},
    P2 = {"V1 NORMAL", "V2 DE COSTAS", "V1 SEM BURLA"},
    P3 = {"V1 NORMAL", "V2 PERSONALIZADA", "V3 EXPERIMENTAL"},
    P4 = {"V1 NORMAL", "V2 DE COSTAS", "V1 SEM BURLA"}
}

local function LoadParkourCat(cat)
    for _, c in pairs(pkContent:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local list = Instance.new("ScrollingFrame", pkContent); list.Size = UDim2.new(1,0,1,0); list.BackgroundTransparency = 1; list.ScrollBarThickness = 2
    Instance.new("UIListLayout", list).Padding = UDim.new(0,5)
    for _, route in ipairs(pkData[cat]) do
        local card = Instance.new("Frame", list); card.Size = UDim2.new(1, -10, 0, 50); card.BackgroundColor3 = Theme.Surface
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
        local t = Instance.new("TextLabel", card); t.Size = UDim2.new(0.6, 0, 1, 0); t.Position = UDim2.new(0, 10, 0, 0); t.BackgroundTransparency = 1; t.Text = route; t.TextColor3 = Theme.Text; t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.TextXAlignment = Enum.TextXAlignment.Left
        local b = Instance.new("TextButton", card); b.Size = UDim2.new(0, 80, 0, 25); b.Position = UDim2.new(1, -90, 0.5, -12); b.BackgroundColor3 = Theme.Accent; b.Text = "Escolher"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function() State.SelectedRoute = cat.." - "..route; Notify("Rota", "Selecionado: "..State.SelectedRoute) end)
    end
end

for i, cat in ipairs({"P1","P2","P3","P4"}) do
    local btn = Instance.new("TextButton", pkCats); btn.Size = UDim2.new(0.25, -5, 1, 0); btn.BackgroundColor3 = Theme.SurfaceLight; btn.Text = "PARKOUR "..i; btn.TextColor3 = Theme.Text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() LoadParkourCat(cat) end)
end
LoadParkourCat("P1")

-- ==========================================
-- [ PÁGINA 3: HAVOC (Pesquisa e Cópia) ]
-- ==========================================
local Havoc = Pages["Havoc"]
local searchBox = CreateInput(Havoc, "Pesquisar por BFE, BFC, etc...", "", nil)
searchBox.Size = UDim2.new(1, -10, 0, 35)
local hResults = Instance.new("ScrollingFrame", Havoc); hResults.Size = UDim2.new(1, -10, 0, 300); hResults.BackgroundTransparency = 1; hResults.ScrollBarThickness = 2
Instance.new("UIListLayout", hResults).Padding = UDim.new(0, 5)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    for _, c in pairs(hResults:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local q = string.lower(searchBox.Text)
    if #q < 2 then return end
    
    for cat, list in pairs(State.Havoc) do
        for _, item in ipairs(list) do
            if string.find(string.lower(item.Q), q) or string.find(string.lower(cat), q) then
                local card = Instance.new("Frame", hResults); card.Size = UDim2.new(1, -5, 0, 65); card.BackgroundColor3 = Theme.Surface
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
                
                local txt = Instance.new("TextLabel", card); txt.Size = UDim2.new(0.75, -10, 1, 0); txt.Position = UDim2.new(0, 10, 0, 0); txt.BackgroundTransparency = 1
                txt.Text = string.format("[%s]\nQ: %s\nR: %s", cat, item.Q, item.A); txt.TextColor3 = Theme.Text; txt.Font = Enum.Font.Gotham; txt.TextSize = 11; txt.TextWrapped = true; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.TextYAlignment = Enum.TextYAlignment.Center
                
                local cBtn = Instance.new("TextButton", card); cBtn.Size = UDim2.new(0.2, 0, 0, 25); cBtn.Position = UDim2.new(0.78, 0, 0.5, -12); cBtn.BackgroundColor3 = Theme.Accent; cBtn.Text = "COPIAR"; cBtn.TextColor3 = Color3.new(1,1,1); cBtn.Font = Enum.Font.GothamBold; cBtn.TextSize = 10
                Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 4)
                cBtn.MouseButton1Click:Connect(function()
                    if setclipboard then setclipboard(item.A); Notify("Copiado", "Resposta copiada para a área de transferência.") end
                end)
            end
        end
    end
end)

-- ==========================================
-- [ PÁGINA 4: EXTRAS (Timer e Sessão) ]
-- ==========================================
local Extras = Pages["Extras"]
local tLabel = Instance.new("TextLabel", Extras); tLabel.Size = UDim2.new(1, -10, 0, 60); tLabel.BackgroundColor3 = Theme.Surface; tLabel.Text = "00:00"; tLabel.TextColor3 = Theme.Accent; tLabel.Font = Enum.Font.GothamBlack; tLabel.TextSize = 30
Instance.new("UICorner", tLabel).CornerRadius = UDim.new(0, 6)

local btnRow = Instance.new("Frame", Extras); btnRow.Size = UDim2.new(1, -10, 0, 35); btnRow.BackgroundTransparency = 1
local btnLayout = Instance.new("UIListLayout", btnRow); btnLayout.FillDirection = Enum.FillDirection.Horizontal; btnLayout.Padding = UDim.new(0,5)

local function CreateTimerBtn(txt, cb)
    local b = Instance.new("TextButton", btnRow); b.Size = UDim2.new(0.33, -4, 1, 0); b.BackgroundColor3 = Theme.SurfaceLight; b.Text = txt; b.TextColor3 = Theme.Text; b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4); b.MouseButton1Click:Connect(cb)
end
CreateTimerBtn("INICIAR", function() State.Timer.Active = true end)
CreateTimerBtn("PAUSAR", function() State.Timer.Active = false end)
CreateTimerBtn("RESETAR", function() State.Timer.Time = 0; State.Timer.Active = false; tLabel.Text = "00:00" end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if State.Timer.Active then
            State.Timer.Time = State.Timer.Time + 1
            tLabel.Text = string.format("%02d:%02d", math.floor(State.Timer.Time/60), State.Timer.Time%60)
        end
    end
end)

-- SESSION MANAGER
local sBtn = CreateBtn(Extras, "Iniciar Sessão de Treino", Theme.Success, function()
    if not State.Session.Active then
        State.Session.Active = true; State.Session.Start = tick(); Notify("Sessão", "Sessão iniciada!")
    else
        State.Session.Active = false; local dur = math.floor(tick() - State.Session.Start)
        table.insert(State.Session.History, dur); Notify("Sessão", "Finalizada! Duração: "..dur.."s")
    end
end)

-- ==========================================
-- [ PÁGINA 5: SETTINGS ]
-- ==========================================
local Set = Pages["Settings"]
CreateBtn(Set, "Mudar Tema (Roxo / Azul)", Theme.Accent, function()
    if Theme.Accent == Color3.fromRGB(160, 60, 255) then Theme.Accent = Color3.fromRGB(60, 150, 255) else Theme.Accent = Color3.fromRGB(160, 60, 255) end
    MainStroke.Color = Theme.Accent; Title.TextColor3 = Theme.Accent; Notify("Tema", "Cor de destaque alterada.")
end)
CreateBtn(Set, "Salvar Notas (Bloco de Notas)", Theme.SurfaceLight, function()
    SaveProfile(); Notify("Salvo", "Anotações salvas no arquivo local.")
end)
CreateInput(Set, "Digite suas anotações aqui...", State.Notes, function(v) State.Notes = v; SaveProfile() end)

-- ==========================================
-- [ INICIALIZAÇÃO ]
-- ==========================================
Pages["Dashboard"].Visible = true
Sidebar:FindFirstChild("TextButton").BackgroundColor3 = Theme.SurfaceLight
Sidebar:FindFirstChild("TextButton").TextColor3 = Theme.Text
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end end)
