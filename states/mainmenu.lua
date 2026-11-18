local display = require 'lib/display'
require 'objects/button'

local menuparticles = require 'objects/menuparticles'

local audio = require "lib/wave"

mainmenu = {}

local mainLogoButton, mainPlayButton, mainOptionsButton, mainExitButton
local optionsLogoButton, optionsResolutionButton, optionsVolumeButton, optionsBackButton
local levelsLogoButton

local menuState, menuBG

function mainmenu:load()
  menuState = "main"
  menuBG = love.graphics.newImage("assets/menubg.jpg")

  mainLogoButton = newButton(gw / 2-330-15, gh / 2 - 130, 180, "2003", "", true, Lavender, White, 0, -34)
  mainPlayButton = newButton(gw / 2-100, gh / 2 + 85, 150, "Play", "", false, Green, White, 0, -23, function() menuState = "levels" end, function() menuState = "levels" end)
  mainOptionsButton = newButton(gw / 2+130, gh / 2 - 85, 150, "Options", "", false, Blue, White, 0, -23, function() mainmenu:openOptions() end, function() mainmenu:openOptions() end)
  if not webBuild then
    mainExitButton = newButton(gw / 2+360, gh / 2 + 85, 150, "Exit", "", false, Red, White, 0, -23, function() love.event.quit() end, function() love.event.quit() end)
  end

  optionsLogoButton = newButton(gw / 2-330-15, gh / 2 - 130, 180, "Options", "", true, Lavender, White, 0, -34)
  if not webBuild then
    optionsResolutionButton = newButton(gw / 2-100, gh / 2 + 85, 150, "Resolution", display.label(), false, Green, White, 0, -23, function() mainmenu:changeResolution(1) end, function() mainmenu:changeResolution(-1) end)
  end
  optionsVolumeButton = newButton(gw / 2+130, gh / 2 - 85, 150, "Volume", volumeValue .. "%", false, Blue, White, 0, -23, function() mainmenu:changeVolume(5) end, function() mainmenu:changeVolume(-5) end)
  optionsBackButton = newButton(gw / 2+360, gh / 2 + 85, 150, "Back", "", false, Red, White, 0, -23, function() mainmenu:saveSettings() menuState = "main" end, function() mainmenu:saveSettings() menuState = "main" end)

  if webBuild then
    optionsVolumeButton.x, optionsVolumeButton.y = mainPlayButton.x, mainPlayButton.y
    optionsBackButton.x, optionsBackButton.y = mainOptionsButton.x, mainOptionsButton.y
  end

  levelsLogoButton = newButton(gw / 2-330-15, gh / 2 - 130, 180, "Levels", "", true, Lavender, White, 0, -34)
  Levels1Button = newButton(gw / 2-100, gh / 2 + 85, 150, "Super", savemanager.highscores.levelScore[1] .. "%", false, Green, White, 0, -23, function() mainmenu:startLevel(1) end, function() mainmenu:startLevel(1) end)
  Levels2Button = newButton(gw / 2+130, gh / 2 - 85, 150, "Hyper", savemanager.highscores.levelScore[2] .. "%", false, Blue, White, 0, -23, function() mainmenu:startLevel(2) end, function() mainmenu:startLevel(2) end)
  Levels3Button = newButton(gw / 2+360, gh / 2 + 85, 150, "Ultra", savemanager.highscores.levelScore[3] .. "%", false, Red, White, 0, -23, function() mainmenu:startLevel(3) end, function() mainmenu:startLevel(3) end)
  Levels4Button = newButton(gw / 2+590, gh / 2 - 85, 150, "Extreme", savemanager.highscores.levelScore[4] .. "%", false, Purple, White, 0, -23, function() mainmenu:startLevel(4) end, function() mainmenu:startLevel(4) end)

  buttonhover = audio:newSource("assets/buttonhover.wav", "stream")
  buttonhover:setVolume(volumeValue * 0.001)

  buttonhit = audio:newSource("assets/buttonhit.wav", "stream")
  buttonhit:setVolume(volumeValue * 0.001)

  menumusic = audio:newSource("songs/OcularNebula - Pulsar.mp3", "stream")
  menumusic:setVolume(volumeValue * 0.001)
  menumusic:setLooping(true)
  menumusic:play()
end

function mainmenu:startLevel(index)
  menumusic:stop()
  menuparticles:clearParticles()
  statemanager:changeState("game")
  maingame:loadLevel(index)
end

function mainmenu:openOptions()
  if optionsResolutionButton then
    display.refresh(display.width())
    optionsResolutionButton:setAltText(display.label())
  end
  menuState = "options"
end

function mainmenu:saveSettings()
  if changedResolution then
    display.apply()
    changedResolution = false
  end
  savemanager:saveSettings(display.width(), volumeValue)
end

function mainmenu:update(dt)
  menuparticles:update(dt)
  if (menuState == "main") then
    mainPlayButton:update(dt)
    mainOptionsButton:update(dt)
    if mainExitButton then mainExitButton:update(dt) end
  elseif (menuState == "options") then
    if optionsResolutionButton then optionsResolutionButton:update(dt) end
    optionsVolumeButton:update(dt)
    optionsBackButton:update(dt)
  elseif (menuState == "levels") then
    Levels1Button:update(dt)
    Levels2Button:update(dt)
    Levels3Button:update(dt)
    Levels4Button:update(dt)
  end
end

function mainmenu:draw()
  love.graphics.draw(menuBG, 0, 0)
  love.graphics.setColor(0, 0, 0, 0.25)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  menuparticles:draw()
  if (menuState == "main") then
    mainLogoButton:draw()
    mainPlayButton:draw()
    mainOptionsButton:draw()
    if mainExitButton then mainExitButton:draw() end
  elseif (menuState == "options") then
    optionsLogoButton:draw()
    if optionsResolutionButton then optionsResolutionButton:draw() end
    optionsVolumeButton:draw()
    optionsBackButton:draw()
  elseif (menuState == "levels") then
    levelsLogoButton:draw()
    Levels1Button:draw()
    Levels2Button:draw()
    Levels3Button:draw()
    Levels4Button:draw()
  end
  cursor:draw()
end

function mainmenu:mousepressed(x, y, button)
  if (menuState == "main") then
    mainPlayButton:mousepressed(x, y, button)
    mainOptionsButton:mousepressed(x, y, button)
    if mainExitButton then mainExitButton:mousepressed(x, y, button) end
  elseif (menuState == "options") then
    if optionsResolutionButton then optionsResolutionButton:mousepressed(x, y, button) end
    optionsVolumeButton:mousepressed(x, y, button)
    optionsBackButton:mousepressed(x, y, button)
  elseif (menuState == "levels") then
    Levels1Button:mousepressed(x, y, button)
    Levels2Button:mousepressed(x, y, button)
    Levels3Button:mousepressed(x, y, button)
    Levels4Button:mousepressed(x, y, button)
  end
end

function mainmenu:keypressed(key)
  if (menuState == "options") then
    if (key == "escape") then
      self:saveSettings()
      menuState = "main"
    end
  elseif (menuState == "levels") then
    if (key == "escape") then
      menuState = "main"
    end
  end
end

function mainmenu:changeResolution(value)
  if webBuild then return end
  display.cycle(value)
  changedResolution = true
  optionsResolutionButton:setAltText(display.label())
end

function mainmenu:changeVolume(value)
  volumeValue = volumeValue + value
  if (volumeValue < 0) then
    volumeValue = 200
  elseif (volumeValue > 200) then
    volumeValue = 0
  end
  optionsVolumeButton:setAltText(volumeValue .. "%")
  menumusic:setVolume(volumeValue * 0.001)
  buttonhover:setVolume(volumeValue * 0.001)
  buttonhit:setVolume(volumeValue * 0.001)
  circlehitsound:setVolume(volumeValue * 0.001)
  failsound:setVolume(volumeValue * 0.001)
end

return mainmenu
