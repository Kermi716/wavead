local imgui = require 'mimgui'
local encoding = require 'encoding'
local requests = require 'requests'
local json = require 'json'
local sampfuncs = require 'sampfuncs'
local sampev = require 'samp.events'
local effil = require("effil")
local ffi = require 'ffi'
local faicons = require('fAwesome6')
local hotkey = require 'mimgui_hotkeys'

encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new

local my_script_version = "1.2" 
local download_url = ""
local json_url = "https://raw.githubusercontent.com/Kermi716/wavead/main/autoupdate.json" 
local update_available = new.bool(false)
local update_version = new.char[32]("")

function compareVersions(v1, v2)
    local v1_parts = {v1:match("(%d+)%.(%d+)%.?(%d*)")}
    local v2_parts = {v2:match("(%d+)%.(%d+)%.?(%d*)")}
    for i = 1, 3 do
        local n1 = tonumber(v1_parts[i]) or 0
        local n2 = tonumber(v2_parts[i]) or 0
        if n1 < n2 then return -1 end
        if n1 > n2 then return 1 end
    end
    return 0
end

function check_for_updates()
    local response = requests.get(json_url)
    if response.status_code == 200 then
        local version_info = json.decode(response.text)
        if version_info.latest_version and version_info.download_url then
            local comparison = compareVersions(my_script_version, version_info.latest_version)
            if comparison < 0 then -
                update_available[0] = true
                update_version = new.char[32](version_info.latest_version)
                download_url = version_info.download_url
                sampAddChatMessage("{ADFF2F}[WaveAd] Доступно обновление! Последняя версия: " .. version_info.latest_version)
                sampAddChatMessage("{00FFFF}Доступно обновление: " .. version_info.latest_version)
            else
                sampAddChatMessage("{ADFF2F}[WaveAd] У вас установлена последняя версия.")
                update_available[0] = false
            end
        else
            sampAddChatMessage("{FF0000}[WaveAd] Неверный формат файла версии")
        end
    else
        sampAddChatMessage("{FF0000}[WaveAd] Невозможно получить информацию о последней версии.")
    end
end

function download_update()
    if download_url ~= "" then
        local response = requests.get(download_url)
        if response.status_code == 200 then
            local file = io.open("moonloader\\Rebild.lua", "w")
            file:write(response.text)
            file:close()
            sampAddChatMessage("{ADFF2F}[WaveAd] Новая версия успешно загружена. Перезапустите скрипт для обновления.", 0xFFFFFF)
            addPopupMessage("{00FFFF}Обновление загружено. Перезапустите скрипт!")
        else
            sampAddChatMessage("{FF0000}[WaveAd] Невозможно загрузить новую версию.", 0xFF0000)
        end
    else
        sampAddChatMessage("{FF0000}[WaveAd] Новая версия не обнаружена. Проверьте обновления!", 0xFFFFFF)
    end
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil 

    local fontPath = getWorkingDirectory() .. "\\config\\fld\\fldfonts.ttf" 
    local fontSize = 15 
    local glyphRanges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic() 
    if doesFileExist(fontPath) then
        example = imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, fontSize, nil, glyphRanges)
        if example == nil then
            print("Не удалось загрузить шрифт из " .. fontPath)
        else
            print("Шрифт успешно загружен из " .. fontPath)
        end
    else
        print("Файл шрифта не найден по пути " .. fontPath .. ", используется шрифт по умолчанию")
        example = imgui.GetIO().Fonts:AddFontDefault()
    end
end)

local themes = {
    { name = "Default", apply = function()
        imgui.SwitchContext()
        local ImVec4 = imgui.ImVec4
        local ImVec2 = imgui.ImVec2
        
        local style = imgui.GetStyle()
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.WindowPadding = ImVec2(5, 5)
        style.FramePadding = ImVec2(5, 5)
        style.ItemSpacing = ImVec2(5, 5)
        style.ItemInnerSpacing = ImVec2(2, 2)
        style.IndentSpacing = 0
        style.ScrollbarSize = 10
        style.GrabMinSize = 10
        style.WindowBorderSize = 1
        style.ChildBorderSize = 1
        style.PopupBorderSize = 1
        style.FrameBorderSize = 1
        style.TabBorderSize = 1
        style.WindowRounding = 6
        style.ChildRounding = 6
        style.FrameRounding = 6
        style.PopupRounding = 6
        style.ScrollbarRounding = 6
        style.GrabRounding = 6
        style.TabRounding = 6
        
        local colors = style.Colors
        colors[imgui.Col.Text] = ImVec4(0.85, 0.90, 0.95, 1.00)          
        colors[imgui.Col.TextDisabled] = ImVec4(0.50, 0.55, 0.60, 1.00) 
        colors[imgui.Col.WindowBg] = ImVec4(0.05, 0.08, 0.12, 0.75)     
        colors[imgui.Col.ChildBg] = ImVec4(0.08, 0.11, 0.15, 1.00)      
        colors[imgui.Col.PopupBg] = ImVec4(0.08, 0.11, 0.15, 0.98)      
        colors[imgui.Col.Border] = ImVec4(0.20, 0.25, 0.30, 1.00)
        colors[imgui.Col.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg] = ImVec4(0.12, 0.18, 0.22, 0.60)
        colors[imgui.Col.FrameBgHovered] = ImVec4(0.18, 0.24, 0.30, 0.80)
        colors[imgui.Col.FrameBgActive] = ImVec4(0.20, 0.28, 0.35, 1.00)
        colors[imgui.Col.TitleBg] = ImVec4(0.10, 0.12, 0.16, 1.00)
        colors[imgui.Col.TitleBgActive] = ImVec4(0.15, 0.20, 0.28, 1.00)
        colors[imgui.Col.MenuBarBg] = ImVec4(0.10, 0.14, 0.18, 1.00)
        colors[imgui.Col.ScrollbarBg] = ImVec4(0.08, 0.10, 0.15, 0.53)
        colors[imgui.Col.ScrollbarGrab] = ImVec4(0.25, 0.30, 0.38, 1.00)
        colors[imgui.Col.Button] = ImVec4(0.30, 0.50, 0.70, 0.75)    
        colors[imgui.Col.ButtonHovered] = ImVec4(0.40, 0.60, 0.80, 1.00) 
        colors[imgui.Col.ButtonActive] = ImVec4(0.50, 0.70, 0.90, 1.00) 
        colors[imgui.Col.Header] = ImVec4(0.20, 0.26, 0.35, 0.85)
        colors[imgui.Col.HeaderHovered] = ImVec4(0.25, 0.32, 0.42, 0.90)
        colors[imgui.Col.HeaderActive] = ImVec4(0.28, 0.36, 0.48, 1.00)
        colors[imgui.Col.Separator] = ImVec4(0.30, 0.35, 0.40, 1.00)
        colors[imgui.Col.SeparatorHovered] = ImVec4(0.40, 0.45, 0.50, 0.78)
        colors[imgui.Col.SeparatorActive] = ImVec4(0.50, 0.55, 0.60, 1.00)
        colors[imgui.Col.ResizeGrip] = ImVec4(0.20, 0.25, 0.30, 0.50)
        colors[imgui.Col.ResizeGripHovered] = ImVec4(0.28, 0.35, 0.42, 0.75)
        colors[imgui.Col.ResizeGripActive] = ImVec4(0.35, 0.42, 0.50, 1.00)
        colors[imgui.Col.PlotLines] = ImVec4(0.50, 0.55, 0.60, 1.00)
        colors[imgui.Col.PlotHistogram] = ImVec4(0.60, 0.65, 0.70, 1.00)
        colors[imgui.Col.TextSelectedBg] = ImVec4(0.18, 0.50, 0.75, 0.35)
    end},
    { name = "Dark", apply = function()
        imgui.SwitchContext()
        local ImVec4 = imgui.ImVec4
        local ImVec2 = imgui.ImVec2
        
        local style = imgui.GetStyle()
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.WindowPadding = ImVec2(5, 5)
        style.FramePadding = ImVec2(5, 5)
        style.ItemSpacing = ImVec2(5, 5)
        style.ItemInnerSpacing = ImVec2(2, 2)
        style.IndentSpacing = 0
        style.ScrollbarSize = 10
        style.GrabMinSize = 10
        style.WindowBorderSize = 1
        style.ChildBorderSize = 1
        style.PopupBorderSize = 1
        style.FrameBorderSize = 1
        style.TabBorderSize = 1
        style.WindowRounding = 6
        style.ChildRounding = 6
        style.FrameRounding = 6
        style.PopupRounding = 6
        style.ScrollbarRounding = 6
        style.GrabRounding = 6
        style.TabRounding = 6
        
        local colors = style.Colors
        colors[imgui.Col.Text] = ImVec4(0.88, 0.88, 0.88, 1.00)
        colors[imgui.Col.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg] = ImVec4(0.10, 0.10, 0.10, 0.75)
        colors[imgui.Col.ChildBg] = ImVec4(0.15, 0.15, 0.15, 1.00)
        colors[imgui.Col.PopupBg] = ImVec4(0.12, 0.12, 0.12, 0.94)
        colors[imgui.Col.Border] = ImVec4(0.35, 0.35, 0.38, 1.00)
        colors[imgui.Col.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg] = ImVec4(0.20, 0.20, 0.20, 0.54)
        colors[imgui.Col.FrameBgHovered] = ImVec4(0.30, 0.30, 0.30, 0.60)
        colors[imgui.Col.FrameBgActive] = ImVec4(0.40, 0.40, 0.40, 0.75)
        colors[imgui.Col.TitleBg] = ImVec4(0.08, 0.08, 0.08, 1.00)
        colors[imgui.Col.TitleBgActive] = ImVec4(0.25, 0.25, 0.25, 1.00)
        colors[imgui.Col.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[imgui.Col.ScrollbarBg] = ImVec4(0.05, 0.05, 0.05, 0.53)
        colors[imgui.Col.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[imgui.Col.Button] = ImVec4(0.25, 0.25, 0.25, 0.60)
        colors[imgui.Col.ButtonHovered] = ImVec4(0.35, 0.35, 0.35, 1.00)
        colors[imgui.Col.ButtonActive] = ImVec4(0.45, 0.45, 0.45, 1.00)
        colors[imgui.Col.Header] = ImVec4(0.25, 0.25, 0.25, 0.75)
        colors[imgui.Col.HeaderHovered] = ImVec4(0.35, 0.35, 0.35, 0.90)
        colors[imgui.Col.HeaderActive] = ImVec4(0.45, 0.45, 0.45, 1.00)
        colors[imgui.Col.Separator] = ImVec4(0.35, 0.35, 0.38, 1.00)
        colors[imgui.Col.SeparatorHovered] = ImVec4(0.50, 0.50, 0.50, 0.78)
        colors[imgui.Col.SeparatorActive] = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[imgui.Col.ResizeGrip] = ImVec4(0.25, 0.25, 0.25, 0.50)
        colors[imgui.Col.ResizeGripHovered] = ImVec4(0.35, 0.35, 0.35, 0.75)
        colors[imgui.Col.ResizeGripActive] = ImVec4(0.45, 0.45, 0.45, 1.00)
        colors[imgui.Col.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[imgui.Col.PlotHistogram] = ImVec4(0.70, 0.70, 0.70, 1.00)
        colors[imgui.Col.TextSelectedBg] = ImVec4(0.25, 0.50, 0.75, 0.35)
    end},
    { name = "Light", apply = function()
        imgui.SwitchContext()
        local ImVec4 = imgui.ImVec4
        local ImVec2 = imgui.ImVec2
        
        local style = imgui.GetStyle()
        style.WindowPadding = ImVec2(5, 5)
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.FramePadding = ImVec2(5, 5)
        style.ItemSpacing = ImVec2(5, 5)
        style.ItemInnerSpacing = ImVec2(2, 2)
        style.IndentSpacing = 0
        style.ScrollbarSize = 10
        style.GrabMinSize = 10
        style.WindowBorderSize = 1
        style.ChildBorderSize = 1
        style.PopupBorderSize = 1
        style.FrameBorderSize = 1
        style.TabBorderSize = 1
        style.WindowRounding = 6
        style.ChildRounding = 6
        style.FrameRounding = 6
        style.PopupRounding = 6
        style.ScrollbarRounding = 6
        style.GrabRounding = 6
        style.TabRounding = 6
        
        local colors = style.Colors
        colors[imgui.Col.Text] = ImVec4(0.10, 0.10, 0.10, 1.00)
        colors[imgui.Col.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.WindowBg] = ImVec4(0.90, 0.90, 0.90, 0.75)
        colors[imgui.Col.ChildBg] = ImVec4(0.95, 0.95, 0.95, 1.00)
        colors[imgui.Col.PopupBg] = ImVec4(0.97, 0.97, 0.97, 1.00)
        colors[imgui.Col.Border] = ImVec4(0.70, 0.70, 0.70, 1.00)
        colors[imgui.Col.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg] = ImVec4(0.85, 0.85, 0.85, 1.00)
        colors[imgui.Col.FrameBgHovered] = ImVec4(0.80, 0.80, 0.80, 1.00)
        colors[imgui.Col.FrameBgActive] = ImVec4(0.75, 0.75, 0.75, 1.00)
        colors[imgui.Col.TitleBg] = ImVec4(0.80, 0.80, 0.80, 1.00)
        colors[imgui.Col.TitleBgActive] = ImVec4(0.70, 0.70, 0.70, 1.00)
        colors[imgui.Col.MenuBarBg] = ImVec4(0.85, 0.85, 0.85, 1.00)
        colors[imgui.Col.ScrollbarBg] = ImVec4(0.80, 0.80, 0.80, 1.00)
        colors[imgui.Col.ScrollbarGrab] = ImVec4(0.65, 0.65, 0.65, 1.00)
        colors[imgui.Col.Button] = ImVec4(0.75, 0.75, 0.75, 1.00)
        colors[imgui.Col.ButtonHovered] = ImVec4(0.65, 0.65, 0.65, 1.00)
        colors[imgui.Col.ButtonActive] = ImVec4(0.55, 0.55, 0.55, 1.00)
        colors[imgui.Col.Header] = ImVec4(0.75, 0.75, 0.75, 1.00)
        colors[imgui.Col.HeaderHovered] = ImVec4(0.65, 0.65, 0.65, 1.00)
        colors[imgui.Col.HeaderActive] = ImVec4(0.55, 0.55, 0.55, 1.00)
        colors[imgui.Col.Separator] = ImVec4(0.70, 0.70, 0.70, 1.00)
        colors[imgui.Col.SeparatorHovered] = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[imgui.Col.SeparatorActive] = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[imgui.Col.ResizeGrip] = ImVec4(0.75, 0.75, 0.75, 1.00)
        colors[imgui.Col.ResizeGripHovered] = ImVec4(0.65, 0.65, 0.65, 1.00)
        colors[imgui.Col.ResizeGripActive] = ImVec4(0.55, 0.55, 0.55, 1.00)
        colors[imgui.Col.PlotLines] = ImVec4(0.40, 0.40, 0.40, 1.00)
        colors[imgui.Col.PlotHistogram] = ImVec4(0.30, 0.30, 0.30, 1.00)
        colors[imgui.Col.TextSelectedBg] = ImVec4(0.50, 0.75, 1.00, 0.50)        
    end},
    { name = "Night", apply = function()
        imgui.SwitchContext()
        local ImVec4 = imgui.ImVec4
        local ImVec2 = imgui.ImVec2
        
        local style = imgui.GetStyle()
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.WindowPadding = ImVec2(5, 5)
        style.FramePadding = ImVec2(5, 5)
        style.ItemSpacing = ImVec2(5, 5)
        style.ItemInnerSpacing = ImVec2(2, 2)
        style.IndentSpacing = 0
        style.ScrollbarSize = 10
        style.GrabMinSize = 10
        style.WindowBorderSize = 1
        style.ChildBorderSize = 1
        style.PopupBorderSize = 1
        style.FrameBorderSize = 1
        style.TabBorderSize = 1
        style.WindowRounding = 6
        style.ChildRounding = 6
        style.FrameRounding = 6
        style.PopupRounding = 6
        style.ScrollbarRounding = 6
        style.GrabRounding = 6
        style.TabRounding = 6
        
        local colors = style.Colors
        colors[imgui.Col.Text] = ImVec4(0.85, 0.90, 0.95, 1.00) 
        colors[imgui.Col.TextDisabled] = ImVec4(0.50, 0.55, 0.60, 1.00)
        colors[imgui.Col.WindowBg] = ImVec4(0.07, 0.10, 0.15, 0.75)
        colors[imgui.Col.ChildBg] = ImVec4(0.10, 0.14, 0.18, 1.00)
        colors[imgui.Col.PopupBg] = ImVec4(0.10, 0.14, 0.18, 0.98)
        colors[imgui.Col.Border] = ImVec4(0.20, 0.25, 0.30, 1.00)
        colors[imgui.Col.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg] = ImVec4(0.12, 0.18, 0.22, 0.60)
        colors[imgui.Col.FrameBgHovered] = ImVec4(0.18, 0.24, 0.30, 0.80)
        colors[imgui.Col.FrameBgActive] = ImVec4(0.20, 0.28, 0.35, 1.00)
        colors[imgui.Col.TitleBg] = ImVec4(0.10, 0.12, 0.16, 1.00)
        colors[imgui.Col.TitleBgActive] = ImVec4(0.15, 0.20, 0.28, 1.00)
        colors[imgui.Col.MenuBarBg] = ImVec4(0.10, 0.14, 0.18, 1.00)
        colors[imgui.Col.ScrollbarBg] = ImVec4(0.08, 0.10, 0.15, 0.53)
        colors[imgui.Col.ScrollbarGrab] = ImVec4(0.25, 0.30, 0.38, 1.00)
        colors[imgui.Col.Button] = ImVec4(0.16, 0.22, 0.30, 0.75)
        colors[imgui.Col.ButtonHovered] = ImVec4(0.20, 0.28, 0.38, 1.00)
        colors[imgui.Col.ButtonActive] = ImVec4(0.24, 0.32, 0.42, 1.00)
        colors[imgui.Col.Header] = ImVec4(0.20, 0.26, 0.35, 0.85)
        colors[imgui.Col.HeaderHovered] = ImVec4(0.25, 0.32, 0.42, 0.90)
        colors[imgui.Col.HeaderActive] = ImVec4(0.28, 0.36, 0.48, 1.00)
        colors[imgui.Col.Separator] = ImVec4(0.30, 0.35, 0.40, 1.00)
        colors[imgui.Col.SeparatorHovered] = ImVec4(0.40, 0.45, 0.50, 0.78)
        colors[imgui.Col.SeparatorActive] = ImVec4(0.50, 0.55, 0.60, 1.00)
        colors[imgui.Col.ResizeGrip] = ImVec4(0.20, 0.25, 0.30, 0.50)
        colors[imgui.Col.ResizeGripHovered] = ImVec4(0.28, 0.35, 0.42, 0.75)
        colors[imgui.Col.ResizeGripActive] = ImVec4(0.35, 0.42, 0.50, 1.00)
        colors[imgui.Col.PlotLines] = ImVec4(0.50, 0.55, 0.60, 1.00)
        colors[imgui.Col.PlotHistogram] = ImVec4(0.60, 0.65, 0.70, 1.00)
        colors[imgui.Col.TextSelectedBg] = ImVec4(0.18, 0.50, 0.75, 0.35)       
    end},
    { name = "Retro", apply = function()
        imgui.SwitchContext()
        local ImVec4 = imgui.ImVec4
        local ImVec2 = imgui.ImVec2
        
        local style = imgui.GetStyle()
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.WindowPadding = ImVec2(5, 5)
        style.FramePadding = ImVec2(5, 5)
        style.ItemSpacing = ImVec2(5, 5)
        style.ItemInnerSpacing = ImVec2(2, 2)
        style.IndentSpacing = 0
        style.ScrollbarSize = 10
        style.GrabMinSize = 10
        style.WindowBorderSize = 1
        style.ChildBorderSize = 1
        style.PopupBorderSize = 1
        style.FrameBorderSize = 1
        style.TabBorderSize = 1
        style.WindowRounding = 6
        style.ChildRounding = 6
        style.FrameRounding = 6
        style.PopupRounding = 6
        style.ScrollbarRounding = 6
        style.GrabRounding = 6
        style.TabRounding = 6
        
        local colors = style.Colors
        colors[imgui.Col.Text] = ImVec4(0.90, 0.85, 0.80, 1.00) 
        colors[imgui.Col.TextDisabled] = ImVec4(0.55, 0.50, 0.45, 1.00)
        colors[imgui.Col.WindowBg] = ImVec4(0.12, 0.09, 0.07, 0.75) 
        colors[imgui.Col.ChildBg] = ImVec4(0.15, 0.12, 0.10, 1.00)
        colors[imgui.Col.PopupBg] = ImVec4(0.18, 0.14, 0.12, 0.98)
        colors[imgui.Col.Border] = ImVec4(0.30, 0.20, 0.15, 1.00)
        colors[imgui.Col.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[imgui.Col.FrameBg] = ImVec4(0.25, 0.18, 0.15, 0.60)
        colors[imgui.Col.FrameBgHovered] = ImVec4(0.35, 0.25, 0.20, 0.80)
        colors[imgui.Col.FrameBgActive] = ImVec4(0.40, 0.30, 0.25, 1.00)
        colors[imgui.Col.TitleBg] = ImVec4(0.15, 0.12, 0.10, 1.00)
        colors[imgui.Col.TitleBgActive] = ImVec4(0.28, 0.20, 0.15, 1.00)
        colors[imgui.Col.MenuBarBg] = ImVec4(0.18, 0.14, 0.12, 1.00)
        colors[imgui.Col.ScrollbarBg] = ImVec4(0.10, 0.08, 0.06, 0.53)
        colors[imgui.Col.ScrollbarGrab] = ImVec4(0.45, 0.30, 0.20, 1.00)
        colors[imgui.Col.Button] = ImVec4(0.35, 0.25, 0.20, 0.75)
        colors[imgui.Col.ButtonHovered] = ImVec4(0.45, 0.30, 0.25, 1.00)
        colors[imgui.Col.ButtonActive] = ImVec4(0.50, 0.35, 0.30, 1.00)
        colors[imgui.Col.Header] = ImVec4(0.40, 0.30, 0.25, 0.85)
        colors[imgui.Col.HeaderHovered] = ImVec4(0.50, 0.35, 0.30, 0.90)
        colors[imgui.Col.HeaderActive] = ImVec4(0.55, 0.40, 0.35, 1.00)
        colors[imgui.Col.Separator] = ImVec4(0.45, 0.30, 0.25, 1.00)
        colors[imgui.Col.SeparatorHovered] = ImVec4(0.55, 0.40, 0.35, 0.78)
        colors[imgui.Col.SeparatorActive] = ImVec4(0.60, 0.45, 0.40, 1.00)
        colors[imgui.Col.ResizeGrip] = ImVec4(0.40, 0.30, 0.25, 0.50)
        colors[imgui.Col.ResizeGripHovered] = ImVec4(0.50, 0.35, 0.30, 0.75)
        colors[imgui.Col.ResizeGripActive] = ImVec4(0.60, 0.45, 0.40, 1.00)
        colors[imgui.Col.PlotLines] = ImVec4(0.75, 0.55, 0.40, 1.00)
        colors[imgui.Col.PlotHistogram] = ImVec4(0.85, 0.65, 0.50, 1.00)
        colors[imgui.Col.TextSelectedBg] = ImVec4(0.60, 0.35, 0.20, 0.50)          
    end}
}

local function saveJson(filename, data)
    local fullPath = getWorkingDirectory() .. "\\config\\" .. filename
    local dir = getWorkingDirectory() .. "\\config"
    if not doesDirectoryExist(dir) then
        createDirectory(dir)
    end
    local file = io.open(fullPath, "w")
    if file then
        local function tableToString(t, indent)
            indent = indent or ""
            local str = "{\n"
            for k, v in pairs(t) do
                str = str .. indent .. "  [" .. (type(k) == "number" and k or '"' .. k .. '"') .. "] = "
                if type(v) == "table" then
                    str = str .. tableToString(v, indent .. "  ")
                elseif type(v) == "string" then
                    str = str .. '"' .. v .. '"'
                elseif type(v) == "boolean" then
                    str = str .. tostring(v)
                else
                    str = str .. v
                end
                str = str .. ",\n"
            end
            str = str .. indent .. "}"
            return str
        end
        local content = tableToString(data)
        file:write(content)
        file:close()
        return true
    else
        return false
    end
end

local function loadJson(filename)
    local fullPath = getWorkingDirectory() .. "\\config\\" .. filename
    local dir = getWorkingDirectory() .. "\\config"
    
    if not doesDirectoryExist(dir) then
        createDirectory(dir)
    end
    
    local file = io.open(fullPath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content == "" then
            return nil
        end
        local success, result = pcall(function() return loadstring("return " .. content)() end)
        if success and type(result) == "table" then
            return result
        else
            return nil
        end
    else
        local defaultConfig = {
            currentTheme = 0,
            showPopupNotifications = true,
            telegram_chat_id = "", 
            telegram_token = "",  
            menuHotkey = { keys = {0x4A} },
            menuCommand = "cmd",
            binders = {
                { text = "", delay = 1, active = false, autoEnter = false, randomize = false, randomDelays = {}, shortName = "Биндер #1", mediaEnabled = false, mediaStation = 0, hotkey = {} }
            }
        }
        saveJson(filename, defaultConfig)
        return defaultConfig
    end
end

local configPath = "Spamer.json"
local config = loadJson(configPath)
if not config then
    return
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local configFont = imgui.ImFontConfig()
    configFont.MergeMode = true
    configFont.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('Light'), 14, configFont, iconRanges)
    themes[(config.currentTheme or 0) + 1].apply()
end)


local showPopupNotifications = new.bool(config.showPopupNotifications)
local showPopupNotificationsAnimation = new.float(config.showPopupNotifications and 1.0 or 0.0) 
local telegramChatId = new.char[64](config.telegram_chat_id or "")
local telegramToken = new.char[64](config.telegram_token or "")
local popupAnimationProgress = new.float(0.0)
local popupMessages = {}
local popupDuration = 3.0
local buttonAnimations = {
    {hoverProgress = new.float(0.0), isHovered = false},
    {hoverProgress = new.float(0.0), isHovered = false},
    {hoverProgress = new.float(0.0), isHovered = false}
}
local WinState = new.bool()
local CurrentSection = new.int(1)
local currentTheme = new.int(config.currentTheme or 0)
local menuHotkey = config.menuHotkey or { keys = {0x00} }
local menuHotkeyName = "spamer_menu_hotkey"
local menuCommand = config.menuCommand or "cmd"
local spamPending = false
local spamPendingTimer = 0
local dialogState = nil
local dialogTimer = 0

local binders = {}

for i, cfg in ipairs(config.binders or {}) do
    binders[i] = {
        inputField = new.char[256](cfg.text or ""),
        delayField = new.int(cfg.delay or 1),
        autoEnter = new.bool(cfg.autoEnter or false),
        autoEnterAnimation = new.float(0.0),
        randomize = cfg.randomize or false,
        randomDelays = {},
        currentDelayIndex = 1,
        lastSendTime = -math.huge,
        lastPopupTime = -math.huge,
        shortName = new.char[32](u8(cfg.shortName or ("Биндер #" .. i))),
        mediaEnabled = new.bool(cfg.mediaEnabled or false),
        mediaEnabledAnimation = new.float(0.0),
        mediaStation = new.int(cfg.mediaStation or 0),
        hotkey = cfg.hotkey or {},
        hotkeyName = "binder_hotkey_" .. i,
        toggleState = new.bool(cfg.active or false), 
        animationProgress = new.float(cfg.active and 1.0 or 0.0)
    }
    for j, delay in ipairs(cfg.randomDelays or {}) do
        binders[i].randomDelays[j] = new.int(delay)
    end
    if #binders[i].randomDelays == 0 and binders[i].randomize then
        binders[i].randomDelays[1] = new.int(1)
    end
    
    hotkey.RegisterHotKey(binders[i].hotkeyName, false, binders[i].hotkey, function()
        if not sampIsChatInputActive() then
            local text = u8:decode(ffi.string(binders[i].inputField))
            if text ~= "" then
                sampSendChat(text)
            end
        end
    end)
end

function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

local updateid

function sendTelegramNotification(chat_id, token, msg)
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. msg, '', function(result) end)
end

function sendTelegramNotification(chat_id, token, msg)
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. msg, '', function(result) end)
end

function get_telegram_updates(chat_id, token)
    while not updateid do wait(1) end
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        local url = 'https://api.telegram.org/bot' .. token .. '/getUpdates?chat_id=' .. chat_id .. '&offset=-1'
        threadHandle(runner, url, args, processing_telegram_messages, reject)
        wait(0)
    end
end

function getLastUpdate(chat_id, token)
    async_http_request('https://api.telegram.org/bot' .. token .. '/getUpdates?chat_id=' .. chat_id .. '&offset=-1', '', function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok and #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    updateid = res_table.update_id
                end
            else
                updateid = 1
            end
        end
    end)
end

function processing_telegram_messages(result)
    if result then
        local proc_table = decodeJson(result)
        if proc_table.ok and #proc_table.result > 0 then
            local res_table = proc_table.result[1]
            if res_table and res_table.update_id ~= updateid then
                updateid = res_table.update_id
                local message_from_user = res_table.message.text
                if message_from_user then
                    local chat_id = ffi.string(telegramChatId)
                    local token = ffi.string(telegramToken)
                    local text = u8:decode(message_from_user) .. ' '
                    
                    if text:match('^!otladka') then
                        local currentTime = os.clock()
                        local response = "Отладка:\n"
                        for i, binder in ipairs(binders) do
                            if binder.toggleState[0] then
                                local shortName = u8:decode(ffi.string(binder.shortName))
                                local binderText = u8:decode(ffi.string(binder.inputField))
                                local delay = binder.randomize and binder.randomDelays[binder.currentDelayIndex][0] or binder.delayField[0]
                                local timeSinceLastSend = currentTime - binder.lastSendTime
                                local timeLeft = delay - timeSinceLastSend
                                if timeLeft < 0 then timeLeft = 0 end
                                response = response .. string.format("%s: '%s' через %.1f сек\n", shortName, binderText, timeLeft)
                            end
                        end
                        if response == "Отладка:\n" then
                            response = "Нет активных биндеров"
                        end
                        sendTelegramNotification(chat_id, token, response)
                    
                    elseif text:match('^!binder%d+') then
                        local index = tonumber(text:match('^!binder(%d+)'))
                        local arg = text:gsub('!binder%d+ ', '', 1)
                        if index and binders[index] then
                            if #arg > 0 then
                                binders[index].inputField = new.char[256](u8(arg))
                                sendTelegramNotification(chat_id, token, "Текст биндера #" .. index .. " изменён на: " .. arg)
                            else
                                sendTelegramNotification(chat_id, token, "Введите текст для биндера #" .. index .. "!")
                            end
                        else
                            sendTelegramNotification(chat_id, token, "Биндер с номером " .. (index or "не указан") .. " не найден!")
                        end
                    
                    elseif text:match('^!zaderjka%d+') then
                        local index = tonumber(text:match('^!zaderjka(%d+)'))
                        local arg = text:gsub('!zaderjka%d+ ', '', 1)
                        if index and binders[index] then
                            if #arg > 0 and tonumber(arg) then
                                local delay = math.max(tonumber(arg), 1)
                                binders[index].delayField[0] = delay
                                sendTelegramNotification(chat_id, token, "Задержка биндера #" .. index .. " изменена на: " .. delay .. " сек")
                            else
                                sendTelegramNotification(chat_id, token, "Введите число для задержки биндера #" .. index .. "!")
                            end
                        else
                            sendTelegramNotification(chat_id, token, "Биндер с номером " .. (index or "не указан") .. " не найден!")
                        end
                    
                    elseif text:match('^!toggle%d+') then
                        local index = tonumber(text:match('^!toggle(%d+)'))
                        if index and binders[index] then
                            binders[index].toggleState[0] = not binders[index].toggleState[0]
                            local state = binders[index].toggleState[0] and "включён" or "выключен"
                            sendTelegramNotification(chat_id, token, "Автопиар биндера #" .. index .. " " .. state)
                        else
                            sendTelegramNotification(chat_id, token, "Биндер с номером " .. (index or "не указан") .. " не найден!")
                        end
                    
                    elseif text:match('^!togglevr%d+') then
                        local index = tonumber(text:match('^!togglevr(%d+)'))
                        if index and binders[index] then
                            binders[index].autoEnter[0] = not binders[index].autoEnter[0]
                            local state = binders[index].autoEnter[0] and "включён" or "выключен"
                            sendTelegramNotification(chat_id, token, "Режим /vr биндера #" .. index .. " " .. state)
                        else
                            sendTelegramNotification(chat_id, token, "Биндер с номером " .. (index or "не указан") .. " не найден!")
                        end
                    
                    elseif text:match('^!togglead%d') then
                        local index = tonumber(text:match('^!togglead(%d+)'))
                        if index and binders[index] then
                            binders[index].mediaEnabled[0] = not binders[index].mediaEnabled[0]
                            local state = binders[index].mediaEnabled[0] and "включён" or "выключен"
                            sendTelegramNotification(chat_id, token, "Режим СМИ биндера #" .. index .. " " .. state)
                        else
                            sendTelegramNotification(chat_id, token, "Биндер с номером " .. (index or "не указан") .. " не найден!")
                        end
                    
                    else
                        sendTelegramNotification(chat_id, token, "Неизвестная команда!")
                    end
                end
            end
        end
    end
end

function imgui.CustomToggle(label, value, sizeX, sizeY, animationProgress)
    local style = imgui.GetStyle()
    local pos = imgui.GetCursorScreenPos()
    local size = imgui.ImVec2(sizeX or 40, sizeY or 20)
    local drawList = imgui.GetWindowDrawList()
    
    local lineWidth = size.x * 0.8
    local lineHeight = size.y * 0.6
    local lineOffsetX = (size.x - lineWidth) / 2
    local lineOffsetY = (size.y - lineHeight) / 2
    
    local rectMin = imgui.ImVec2(pos.x + lineOffsetX, pos.y + lineOffsetY)
    local rectMax = imgui.ImVec2(pos.x + lineOffsetX + lineWidth, pos.y + lineOffsetY + lineHeight)
    
    imgui.InvisibleButton(label, size)
    local isClicked = imgui.IsItemClicked()
    
    if isClicked then
        value[0] = not value[0]
    end
    
    local targetProgress = value[0] and 1.0 or 0.0
    if animationProgress[0] < targetProgress then
        animationProgress[0] = math.min(animationProgress[0] + 0.1, 1.0)
    elseif animationProgress[0] > targetProgress then
        animationProgress[0] = math.max(animationProgress[0] - 0.1, 0.0)
    end
    
    local bgColorOff = imgui.ImVec4(0.3, 0.3, 0.3, 1.0)
    local bgColorOn = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
    local circleColor = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
    local bgColor = imgui.ImVec4(
        bgColorOff.x + (bgColorOn.x - bgColorOff.x) * animationProgress[0],
        bgColorOff.y + (bgColorOn.y - bgColorOff.y) * animationProgress[0],
        bgColorOff.z + (bgColorOn.z - bgColorOff.z) * animationProgress[0],
        1.0
    )
    
    drawList:AddRectFilled(rectMin, rectMax, imgui.ColorConvertFloat4ToU32(bgColor), lineHeight * 0.5)
    
    local circleRadius = size.y * 0.4
    local circlePosX = pos.x + lineOffsetX + circleRadius + (lineWidth - circleRadius * 2) * animationProgress[0]
    local circlePos = imgui.ImVec2(circlePosX, pos.y + size.y * 0.5)
    drawList:AddCircleFilled(circlePos, circleRadius, imgui.ColorConvertFloat4ToU32(circleColor), 32)
    
    local shadowColor = imgui.ImVec4(0.0, 0.0, 0.0, 0.2)
    drawList:AddCircleFilled(circlePos, circleRadius + 2, imgui.ColorConvertFloat4ToU32(shadowColor), 32)
    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetCursorPosX() + 5)
    imgui.Text(label)
    
    return value[0]
end

local function addPopupMessage(text)
    table.insert(popupMessages, {
        text = text,
        time = os.clock(),
        animation = new.float(0.0)
    })
end

local function processSpam()
    local currentTime = os.clock()
    for i, binder in ipairs(binders) do
        if binder.toggleState[0] then
            local delay
            if binder.randomize and #binder.randomDelays > 0 then
                delay = binder.randomDelays[binder.currentDelayIndex][0]
            else
                delay = binder.delayField[0] 
            end
            local text = u8:decode(ffi.string(binder.inputField))
            if text ~= "" then
                local timeSinceLast = currentTime - binder.lastSendTime
                if timeSinceLast >= delay then
                    if text:match("^/vr") then
                        spamPending = true
                        spamPendingTimer = currentTime
                    end
                    sampSendChat(text)
                    binder.lastSendTime = currentTime
                    if binder.randomize and #binder.randomDelays > 0 then
                        binder.currentDelayIndex = binder.currentDelayIndex + 1
                        if binder.currentDelayIndex > #binder.randomDelays then
                            binder.currentDelayIndex = 1
                        end
                    end
                elseif showPopupNotifications[0] then
                    local timeLeft = delay - timeSinceLast
                    if timeLeft <= 5 and timeLeft > 4.9 then
                        if currentTime - binder.lastPopupTime >= delay then 
                            local shortName = u8:decode(ffi.string(binder.shortName))
                            addPopupMessage(string.format("%s: '%s' через 5 сек", shortName, text))
                            binder.lastPopupTime = currentTime 
                        end
                    end
                end
            end
        end
    end
end


local windowAnimationProgress = new.float(0.0) 
local isOpening = false 

imgui.OnFrame(
    function() 

        return WinState[0] or windowAnimationProgress[0] > 0.0 
    end,
    function(player)

        local animationSpeed = 0.11
        if WinState[0] then

            if windowAnimationProgress[0] < 1.0 then
                windowAnimationProgress[0] = math.min(windowAnimationProgress[0] + animationSpeed, 1.0)
            end
            isOpening = true
        else

            if windowAnimationProgress[0] > 0.0 then
                windowAnimationProgress[0] = math.max(windowAnimationProgress[0] - animationSpeed, 0.0)
            end
            isOpening = false
        end


        if windowAnimationProgress[0] <= 0.0 and not WinState[0] then
            return
        end

        imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        local baseWidth, baseHeight = 700, 300
        local animatedHeight = baseHeight * windowAnimationProgress[0]
        imgui.SetNextWindowSize(imgui.ImVec2(baseWidth, animatedHeight), imgui.Cond.Always)

        local style = imgui.GetStyle()
        local originalAlpha = style.Alpha 
        style.Alpha = windowAnimationProgress[0] 
    imgui.Begin(u8'WaveAd', WinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
    imgui.PushFont(example)
    imgui.SetCursorPosX(670)
    if imgui.ColoredButton(u8' X ', 'F94242', 50) then
        WinState[0] = false 
    end
    imgui.SetCursorPos(imgui.ImVec2(20, 20))
    if imgui.BeginChild('Name', imgui.ImVec2(180, 256), true) then
        local buttonLabels = {
            u8'Создать пиар',
            u8'Настройка пиар',
            u8'Общие настройки'
        }
        
        local buttonHeight = 78.8
        local style = imgui.GetStyle() 

        local buttonAnimations = buttonAnimations or {
            {hoverProgress = {0.0}},
            {hoverProgress = {0.0}},
            {hoverProgress = {0.0}}
        }
        
        for i, label in ipairs(buttonLabels) do
            local anim = buttonAnimations[i]
            local buttonSize = imgui.ImVec2(170, buttonHeight)
            
            local cursorPos = imgui.GetCursorScreenPos()
            local buttonId = '##button' .. i
            
            imgui.InvisibleButton(label .. buttonId, buttonSize)
            local isHovered = imgui.IsItemHovered()
            local isClicked = imgui.IsItemClicked()

            local targetProgress = (isHovered or CurrentSection[0] == i) and 1.0 or 0.0
            if anim.hoverProgress[0] < targetProgress then
                anim.hoverProgress[0] = math.min(anim.hoverProgress[0] + 0.15, 1.0)
            elseif anim.hoverProgress[0] > targetProgress then
                anim.hoverProgress[0] = math.max(anim.hoverProgress[0] - 0.15, 0.0)
            end
            
            local scale = 1.0 + anim.hoverProgress[0] * 0.05
            local animatedSize = imgui.ImVec2(buttonSize.x * scale, buttonSize.y * scale)
            local offset = imgui.ImVec2((buttonSize.x - animatedSize.x) / 2, (buttonSize.y - animatedSize.y) / 2)

            local baseColor = style.Colors[imgui.Col.Button] or imgui.ImVec4(0.2, 0.2, 0.2, 1.0) 
            local hoverColor = style.Colors[imgui.Col.ButtonHovered] or imgui.ImVec4(0.3, 0.3, 0.3, 1.0) 
            local activeColor = CurrentSection[0] == i and (style.Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0.4, 0.4, 0.4, 1.0)) or hoverColor 
            
            local r = baseColor.x + (activeColor.x - baseColor.x) * anim.hoverProgress[0]
            local g = baseColor.y + (activeColor.y - baseColor.y) * anim.hoverProgress[0]
            local b = baseColor.z + (activeColor.z - baseColor.z) * anim.hoverProgress[0]
            local a = baseColor.w + (activeColor.w - baseColor.w) * anim.hoverProgress[0]
            
            local drawList = imgui.GetWindowDrawList()
            drawList:AddRectFilled(
                imgui.ImVec2(cursorPos.x + offset.x, cursorPos.y + offset.y),
                imgui.ImVec2(cursorPos.x + offset.x + animatedSize.x, cursorPos.y + offset.y + animatedSize.y),
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r, g, b, a)),
                4.0 * scale
            )
            
            drawList:AddRectFilled(
                imgui.ImVec2(cursorPos.x + offset.x + 2, cursorPos.y + offset.y + 2),
                imgui.ImVec2(cursorPos.x + offset.x + animatedSize.x + 2, cursorPos.y + offset.y + animatedSize.y + 2),
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0, 0, 0.2 * anim.hoverProgress[0])),
                4.0 * scale
            )
            
            local textSize = imgui.CalcTextSize(label)
            local textPos = imgui.ImVec2(
                cursorPos.x + (buttonSize.x - textSize.x) / 2,
                cursorPos.y + (buttonSize.y - textSize.y) / 2
            )
            drawList:AddText(textPos, imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 1)), label)
            
            if isClicked then
                CurrentSection[0] = i
            end
        end
        imgui.EndChild()
    end
    imgui.SetCursorPos(imgui.ImVec2(225, 20)) 
    if imgui.BeginChild('Content', imgui.ImVec2(430, 260), true) then
        if CurrentSection[0] == 1 then
            for i = 1, #binders do
                local binder = binders[i]
                imgui.SetNextItemWidth(150)
                imgui.InputTextWithHint(u8'Сообщение##' .. i, u8'Текст', binder.inputField, 256)
                imgui.SameLine()
                
                if not binder.randomize then
                    imgui.SetNextItemWidth(100)
                    imgui.InputInt(u8'Задержка (сек)##' .. i, binder.delayField, 1, 5)
                    if binder.delayField[0] < 1 then binder.delayField[0] = 1 end
                else
                    imgui.Text(u8'Рандомизация включена')
                end
            end
            
            if imgui.Button(u8' + ') then
                local newBinder = {
                    inputField = new.char[256](),
                    delayField = new.int(1),
                    autoEnter = new.bool(false),
                    autoEnterAnimation = new.float(0.0),
                    randomize = false,
                    randomDelays = {},
                    currentDelayIndex = 1,
                    lastSendTime = -math.huge,
                    shortName = new.char[32](u8("Биндер #" .. (#binders + 1))),
                    mediaEnabled = new.bool(false),
                    mediaEnabledAnimation = new.float(0.0),
                    mediaStation = new.int(0),
                    hotkey = {},
                    hotkeyName = "binder_hotkey_" .. (#binders + 1),
                    toggleState = new.bool(false),
                    animationProgress = new.float(0.0)
                }
                table.insert(binders, newBinder)
                hotkey.RegisterHotKey(newBinder.hotkeyName, false, newBinder.hotkey, function()
                    local text = u8:decode(ffi.string(newBinder.inputField))
                    if text ~= "" then
                        sampSendChat(text)
                    end
                end)
            end
            imgui.SameLine()
            
            if imgui.Button(u8' - ') and #binders > 1 then
                hotkey.RemoveHotKey(binders[#binders].hotkeyName)
                table.remove(binders, #binders)
            end
            
        elseif CurrentSection[0] == 2 then
            for i = 1, #binders do
                local binder = binders[i]
                local shortName = u8:decode(ffi.string(binder.shortName))
                if imgui.CollapsingHeader(u8(shortName .. '##' .. i)) then
                    imgui.CustomToggle(u8'Включить автопиар', binder.toggleState, nil, nil, binder.animationProgress)
                    
                    imgui.CustomToggle(u8'Режим /vr', binder.autoEnter, nil, nil, binder.autoEnterAnimation)
                    imgui.SameLine()
                    imgui.CustomToggle(u8'Режим СМИ', binder.mediaEnabled, nil, nil, binder.mediaEnabledAnimation)

                    if not binder.tempShortName then
                        binder.tempShortName = new.char[32](binder.shortName)
                    end
                    
                    imgui.SetNextItemWidth(100)
                    imgui.InputTextWithHint(u8'Краткое название##' .. i, u8'Название', binder.tempShortName, 32)
                    
                    imgui.SameLine()
                    if imgui.Button(u8'OK##' .. i) then
                        local newShortName = u8:decode(ffi.string(binder.tempShortName))
                        binder.shortName = new.char[32](u8(newShortName))
                    end
                    
                    if binder.mediaEnabled[0] then
                        local stations = {
                            u8'Los Santos СМИ',
                            u8'Las Venturas СМИ',
                            u8'San Fierro СМИ'
                        }
                        local cStations = ffi.new("const char*[?]", #stations + 1)
                        for j, station in ipairs(stations) do
                            cStations[j - 1] = station
                        end
                        cStations[#stations] = nil
                        imgui.SetNextItemWidth(150)
                        imgui.Combo(u8'Радиостанция', binder.mediaStation, cStations, #stations)
                    end
                    
                    if imgui.Button(u8'Рандомизация') then
                        binder.randomize = true
                        if #binder.randomDelays == 0 then
                            table.insert(binder.randomDelays, new.int(binder.delayField[0]))
                        end
                    end
                    imgui.SameLine()
                    if imgui.Button(u8'Вернуть') then
                        binder.randomize = false
                        binder.randomDelays = {}
                        binder.currentDelayIndex = 1
                    end
                    
                    if binder.randomize then
                        for j = 1, #binder.randomDelays do
                            imgui.SetNextItemWidth(100)
                            imgui.InputInt(u8'Задержка #' .. j, binder.randomDelays[j], 1, 5)
                            if binder.randomDelays[j][0] < 1 then binder.randomDelays[j][0] = 1 end
                        end
                        if imgui.Button(u8' + ') then
                            table.insert(binder.randomDelays, new.int(1))
                        end
                        imgui.SameLine()
                        if imgui.Button(u8' - ') and #binder.randomDelays > 1 then
                            table.remove(binder.randomDelays, #binder.randomDelays)
                            if binder.currentDelayIndex > #binder.randomDelays then
                                binder.currentDelayIndex = 1
                            end
                        end
                    end
                    
                    imgui.Separator()
                    imgui.Text(u8'Горячая клавиша:')
                    if hotkey.ShowHotKey(binder.hotkeyName, imgui.ImVec2(200, 25)) then
                        binder.hotkey = hotkey.GetHotKey(binder.hotkeyName)
                        hotkey.EditHotKey(binder.hotkeyName, binder.hotkey)
                    end
                end
            end
            
        elseif CurrentSection[0] == 3 then
            local themeNames = ffi.new("const char*[?]", #themes)
            for i, theme in ipairs(themes) do
                themeNames[i-1] = u8(theme.name)
            end
            
            imgui.SetNextItemWidth(100)
            if imgui.Combo(u8'Тема', currentTheme, themeNames, #themes) then
                themes[currentTheme[0] + 1].apply()
                local newConfig = { binders = {} }
                for i, binder in ipairs(binders) do
                    local randomDelays = {}
                    for j, delay in ipairs(binder.randomDelays) do
                        randomDelays[j] = delay[0]
                    end
                    newConfig.binders[i] = {
                        text = ffi.string(binder.inputField),
                        delay = binder.delayField[0],
                        autoEnter = binder.autoEnter[0],
                        randomize = binder.randomize,
                        randomDelays = randomDelays,
                        shortName =u8:decode(ffi.string(binder.shortName)),
                        mediaEnabled = binder.mediaEnabled[0],
                        mediaStation = binder.mediaStation[0],
                        hotkey = binder.hotkey
                    }
                end
                newConfig.currentTheme = currentTheme[0]
                newConfig.showPopupNotifications = showPopupNotifications[0]
                saveJson("Spamer.json", newConfig)
                config = newConfig
            end
            if imgui.CustomToggle(u8'Показывать всплывающие уведомления', showPopupNotifications, nil, nil, showPopupNotificationsAnimation) then
                local newConfig = config
                newConfig.showPopupNotifications = showPopupNotifications[0]
                if saveJson("Spamer.json", newConfig) then
                    config = newConfig
                end
            end
            imgui.Text(u8'Горячая клавиша меню:')
            if hotkey.ShowHotKey(menuHotkeyName, imgui.ImVec2(150, 25)) then
                menuHotkey = hotkey.GetHotKey(menuHotkeyName)
                hotkey.EditHotKey(menuHotkeyName, menuHotkey)
                local newConfig = config
                newConfig.menuHotkey = menuHotkey
                newConfig.showPopupNotifications = showPopupNotifications[0]
                saveJson("Spamer.json", newConfig)
            end

            imgui.Text(u8'Команда для открытия:')
            local commandBuffer = new.char[32](menuCommand) 
            imgui.SetNextItemWidth(150)
            if imgui.InputText(u8'##MenuCommand', commandBuffer, 32) then
                menuCommand = ffi.string(commandBuffer) 
                sampRegisterChatCommand(menuCommand, function() 
                    WinState[0] = not WinState[0] 
                end)
                local newConfig = config
                newConfig.menuCommand = menuCommand
                newConfig.showPopupNotifications = showPopupNotifications[0]
                saveJson("Spamer.json", newConfig)
            end
            if imgui.Button(u8'Сохранить') then
                local newConfig = { binders = {} }
                for i, binder in ipairs(binders) do
                    local randomDelays = {}
                    for j, delay in ipairs(binder.randomDelays) do
                        randomDelays[j] = delay[0]
                    end
                    newConfig.binders[i] = {
                        text = ffi.string(binder.inputField),
                        delay = binder.delayField[0],
                        autoEnter = binder.autoEnter[0],
                        randomize = binder.randomize,
                        randomDelays = randomDelays,
                        shortName = u8:decode(ffi.string(binder.shortName)),
                        mediaEnabled = binder.mediaEnabled[0], 
                        mediaStation = binder.mediaStation[0],
                        hotkey = binder.hotkey,
                        active = binder.toggleState[0] 
                    }
                end
                newConfig.showPopupNotifications = showPopupNotifications[0]
                newConfig.currentTheme = currentTheme[0]
                newConfig.telegram_chat_id = ffi.string(telegramChatId)
                newConfig.telegram_token = ffi.string(telegramToken)
                newConfig.menuHotkey = menuHotkey 
                newConfig.menuCommand = menuCommand
                saveJson("Spamer.json", newConfig)
                config = newConfig
            end
            if imgui.CollapsingHeader(u8'Обновления') then
                imgui.Text(u8("Текущая версия: " .. my_script_version))
                if update_available[0] then
                    imgui.Text(u8("Доступна версия: " .. ffi.string(update_version)))
                end
                
                if imgui.Button(u8'Проверить обновления') then
                    lua_thread.create(check_for_updates)
                end
                
                if update_available[0] then
                    imgui.SameLine()
                    if imgui.Button(u8'Загрузить обновление') then
                        lua_thread.create(download_update)
                    end
                end
            end
            if imgui.CollapsingHeader(u8'Telegram') then
                imgui.SetNextItemWidth(200)
                imgui.InputTextWithHint(u8'Chat ID', u8'Введите Chat ID', telegramChatId, 64)
                
                imgui.SetNextItemWidth(200)
                imgui.InputTextWithHint(u8'Bot Token', u8'Введите Token бота', telegramToken, 64)
                
                if imgui.Button(u8'Проверить') then
                    local chatIdStr = ffi.string(telegramChatId)
                    local tokenStr = ffi.string(telegramToken)
                    if chatIdStr ~= "" and tokenStr ~= "" then
                        sendTelegramNotification(chatIdStr, tokenStr, "Я подключен")
                        sampAddChatMessage("{ADFF2F}[WaveAd] Отправлено тестовое сообщение в Telegram!", -1)
                    else
                        sampAddChatMessage("{DC143C}[WaveAd] Введите Chat ID и Token!", -1)
                    end
                end
            end
            if imgui.CollapsingHeader(u8'Отладка') then
                local currentTime = os.clock()
                imgui.PushTextWrapPos(imgui.GetContentRegionAvail().x) 
                for i, binder in ipairs(binders) do
                    if binder.toggleState[0] then
                        local shortName = u8:decode(ffi.string(binder.shortName))
                        local text = u8:decode(ffi.string(binder.inputField))
                        local delay = binder.randomize and binder.randomDelays[binder.currentDelayIndex][0] or binder.delayField[0]
                        local timeSinceLastSend = currentTime - binder.lastSendTime
                        local timeLeft = delay - timeSinceLastSend
                        
                        if timeLeft < 0 then timeLeft = 0 end
                        
                        imgui.TextWrapped(u8(string.format("%s: '%s' будет отправлено через %.1f сек", shortName, text, timeLeft)))
                    end
                end
                imgui.PopTextWrapPos()
            end
        end
        imgui.EndChild() 
        imgui.PopFont()
    end
    imgui.End()
    style.Alpha = originalAlpha
end)

imgui.OnFrame(
    function() return showPopupNotifications[0] and #popupMessages > 0 end,
    function()
        local screenWidth, screenHeight = getScreenResolution()
        local popupWidth = 300
        local popupHeight = 40
        local spacing = 5
        local currentY = screenHeight - 50
        
        for i = #popupMessages, 1, -1 do
            local msg = popupMessages[i]
            local timeSinceStart = os.clock() - msg.time
            

            if timeSinceStart < 0.3 then
                msg.animation[0] = math.min(msg.animation[0] + 0.05, 1.0)
            elseif timeSinceStart > popupDuration - 0.3 then
                msg.animation[0] = math.max(msg.animation[0] - 0.05, 0.0)
            end
            
            if timeSinceStart > popupDuration then
                table.remove(popupMessages, i)
            else
                local alpha = msg.animation[0]
                imgui.SetNextWindowPos(imgui.ImVec2(screenWidth - popupWidth - 10, currentY), imgui.Cond.Always)
                imgui.SetNextWindowSize(imgui.ImVec2(popupWidth, popupHeight), imgui.Cond.Always)
                
                local style = imgui.GetStyle()
                local oldAlpha = style.Alpha
                style.Alpha = alpha
                
                imgui.Begin(u8'Popup##'..i, nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + 
                    imgui.WindowFlags.NoMove + imgui.WindowFlags.NoSavedSettings)
                
                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                imgui.TextWrapped(u8(msg.text))
                
                imgui.End()
                style.Alpha = oldAlpha
                
                currentY = currentY - (popupHeight + spacing)
            end
        end
    end
).HideCursor = true

function sampAddRandomColorMessage(text)
    local function getRandomColor()
        return string.format("{%02X%02X%02X}", math.random(0, 255), math.random(0, 255), math.random(0, 255))
    end
    local coloredText = ""
    for i = 1, #text do
        local char = text:sub(i, i)
        local color = getRandomColor()
        coloredText = coloredText .. color .. char
    end
    sampAddChatMessage(coloredText, -1)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    local currentTime = os.clock()
    if spamPending and (currentTime - spamPendingTimer > 2) then
        spamPending = false
    end

    if dialogId == 25624 then
        if spamPending then 
            for i, binder in ipairs(binders) do
                if binder.autoEnter[0] and binder.toggleState[0] then
                    local expectedText = u8:decode(ffi.string(binder.inputField))
                    if expectedText:match("^/vr") then
                        sampSendDialogResponse(dialogId, 1, 0, expectedText)
                        spamPending = false 
                        return false 
                    end
                end
            end
        end
    end
    
    if dialogId == 25477 then
        for i, binder in ipairs(binders) do
            if binder.toggleState[0] and binder.mediaEnabled[0] then
                sampSendDialogResponse(dialogId, 1, binder.mediaStation[0], nil)
                dialogState = { dialogId = 25477 }
                dialogTimer = os.clock()
                return false
            end
        end
    end
    
    if dialogId == 15346 then
        for i, binder in ipairs(binders) do
            if binder.toggleState[0] and binder.mediaEnabled[0] then
                sampSendDialogResponse(dialogId, 1, 0, nil)
                dialogState = { dialogId = 15346 }
                dialogTimer = os.clock()
                return false
            end
        end
    end
    
    if dialogId == 15347 then
        for i, binder in ipairs(binders) do
            if binder.toggleState[0] and binder.mediaEnabled[0] then
                sampSendDialogResponse(dialogId, 1, 0, nil)
                dialogState = { dialogId = 15347 }
                dialogTimer = os.clock()
                return false
            end
        end
    end
    
    if dialogId == 15379 then
        for i, binder in ipairs(binders) do
            if binder.toggleState[0] and binder.mediaEnabled[0] then
                sampSendDialogResponse(dialogId, 2, 0, nil)
                dialogState = { dialogId = 15379 }
                dialogTimer = os.clock()
                return false
            end
        end
    end
end

function imgui.ColoredButton(text, hex, trans, size)
    local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
    if tonumber(trans) ~= nil and tonumber(trans) < 101 and tonumber(trans) > 0 then a = trans else a = 60 end
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r/255, g/255, b/255, a/100))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r/255, g/255, b/255, a/100))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r/255, g/255, b/255, a/100))
    local button = imgui.Button(text, size)
    imgui.PopStyleColor(3)
    return button
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do 
        wait(100) 
    end
    repeat
        wait(0)
    until sampIsLocalPlayerSpawned()

    sampAddRandomColorMessage('[WaveAd] ЗАГРУЖАЮСЬ')
    wait(1500)  
    sampAddRandomColorMessage('[WaveAd] Все!')
    sampAddRandomColorMessage('[WaveAd] команда /' .. menuCommand)
    sampRegisterChatCommand(menuCommand, function() 
        WinState[0] = not WinState[0] 
    end)
    hotkey.RegisterHotKey(menuHotkeyName, false, menuHotkey, function()
        if not sampIsChatInputActive() then
            WinState[0] = true
        end
    end)

    local chat_id = ffi.string(telegramChatId)
    local token = ffi.string(telegramToken)
    if chat_id ~= "" and token ~= "" then
        getLastUpdate(chat_id, token)
        lua_thread.create(function()
            get_telegram_updates(chat_id, token)
        end)
        sampAddRandomColorMessage("[WaveAd] Telegram-бот запущен!", -1)
    else
        sampAddChatMessage("{DC143C}[WaveAd] Укажите Chat ID и Token для Telegram в настройках!", -1)
    end
    
    menuHotkey = config.menuHotkey or {0x00}
    hotkey.CancelKey = 0x2E
    hotkey.RemoveKey = 0x1B
    hotkey.Text.NoKey = u8'Пусто'
    hotkey.Text.WaitForKey = u8'Ожидание клавиши...'
    
    check_for_updates()

    while true do
        wait(0)
        processSpam()
        
        local currentTime = os.clock()
        if dialogState then
            if dialogState.dialogId == 25477 and currentTime - dialogTimer >= 0.1 then
                sampSendDialogResponse(25477, 1, 0, nil)
                dialogState = nil
            elseif dialogState.dialogId == 15346 and currentTime - dialogTimer >= 0.1 then
                sampSendDialogResponse(15346, 1, 0, nil)
                dialogState = nil
            elseif dialogState.dialogId == 15347 and currentTime - dialogTimer >= 0.1 then
                sampSendDialogResponse(15347, 1, 0, nil)
                dialogState = nil
            elseif dialogState.dialogId == 15379 and currentTime - dialogTimer >= 0.1 then
                sampSendDialogResponse(15379, 2, 0, nil)
                dialogState = nil
            end
        end
    end
end
