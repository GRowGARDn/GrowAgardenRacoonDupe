-- Проверка на повторную загрузку
if _G.BOBI_LOADED then return end
_G.BOBI_LOADED = true

-- Настройки
local Settings = {
    Notify = false,
    Webhook = "",
    VideoUrls = {
        "https://example.com/video1.mp4",
        "https://example.com/video2.mp4"
    },
    SoundUrls = {
        "https://example.com/sound1.mp3",
        "https://example.com/sound2.mp3"
    },
    MaxVideos = 5,
    Volume = 0.5
}

-- Локальные переменные
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local ActiveMedia = {}

-- Безопасная функция загрузки контента
local function loadContent(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    return success and result or nil
end

-- Создание видео-элемента
local function createVideoPlayer()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("CoreGui")
    
    local videoFrame = Instance.new("VideoFrame")
    videoFrame.Size = UDim2.new(0, 400, 0, 300)
    videoFrame.Position = UDim2.new(
        math.random(), 0,
        math.random(), 0
    )
    videoFrame.Parent = screenGui
    
    return videoFrame
end

-- Воспроизведение медиа внутри Roblox
local function playSafeMedia()
    for i = 1, math.min(#Settings.VideoUrls, Settings.MaxVideos) do
        local videoUrl = Settings.VideoUrls[i]
        local soundUrl = Settings.SoundUrls[i]
        
        -- Создаем видео-плеер
        local video = createVideoPlayer()
        video.Video = videoUrl
        video.Volume = Settings.Volume
        video.Playing = true
        
        -- Воспроизводим звук (если доступен)
        if soundUrl then
            local sound = Instance.new("Sound")
            sound.SoundId = soundUrl
            sound.Volume = Settings.Volume
            sound.Parent = workspace
            sound:Play()
            table.insert(ActiveMedia, sound)
        end
        
        table.insert(ActiveMedia, video)
        
        -- Анимация перемещения
        spawn(function()
            while video.Parent do
                video.Position = UDim2.new(
                    math.random(), 0,
                    math.random(), 0
                )
                wait(2)
            end
        end)
        
        wait(math.random(3, 7))
    end
end

-- Очистка ресурсов
local function cleanup()
    for _, media in ipairs(ActiveMedia) do
        pcall(function()
            if media:IsA("Sound") then
                media:Stop()
            end
            media:Destroy()
        end)
    end
    ActiveMedia = {}
end

-- Запуск
playSafeMedia()

-- Автоочистка при выходе
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)
