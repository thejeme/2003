require 'objects/circle'

maingame = {}

local levelIndex, timer, notesPassed, isPause, isFailed, isWin
local maxFrameTime = 0.1
local maxStep = 1 / 120

function maingame:pauseForInterruption()
  if self:isPlaying() then self:pause() end
end

function maingame:load()
  levelSongs = {love.audio.newSource("songs/DJ Okawari - Flower Dance.mp3", "stream"),
                love.audio.newSource("songs/Goukisan - Betrayal Of Fate.mp3", "stream"),
                love.audio.newSource("songs/Goukisan - Betrayal Of Fear.mp3", "stream"),
                love.audio.newSource("songs/kors k - Erehamonika.mp3", "stream")}

  levelBGs = {love.graphics.newImage("assets/level1bg.jpg"),
                love.graphics.newImage("assets/level2bg.jpg"),
                love.graphics.newImage("assets/level3bg.jpg"),
                love.graphics.newImage("assets/level4bg.jpg")}

  pauseLogoButton = newButton(gw / 2-330-15, gh / 2 - 130, 180, "Paused", "", true, Lavender, White, 0, -34)
  pauseContinueButton = newButton(gw / 2-100, gh / 2 + 85, 150, "Continue", "", false, Green, White, 0, -23, function() maingame:pause() end, function() maingame:pause() end)
  pauseProgressButton = newButton(gw / 2-100, gh / 2 + 85, 150, "", "", false, Green, White, 0, -23)
  pauseRestartButton = newButton(gw / 2+130, gh / 2 - 85, 150, "Restart", "", false, Blue, White, 0, -23, function() maingame:restart() end, function() maingame:restart() end)
  pauseQuitButton = newButton(gw / 2+360, gh / 2 + 85, 150, webBuild and "Levels" or "Quit", "", false, Red, White, 0, -23, function() maingame:endLevel() end, function() maingame:endLevel() end)

  circlehitsound = love.audio.newSource("assets/circlehit.wav", "static")
  circlehitsound:setVolume(volumeValue * 0.001)

  failsound = love.audio.newSource("assets/fail.wav", "static")
  failsound:setVolume(volumeValue * 0.001)
end

function maingame:update(dt)
  if dt > maxFrameTime then
    self:pauseForInterruption()
    dt = 0
  end

  if isWin then
    pauseRestartButton:update(dt)
    pauseQuitButton:update(dt)
  elseif isPause then
    pauseContinueButton:update(dt)
    pauseRestartButton:update(dt)
    pauseQuitButton:update(dt)
  elseif isFailed then
    pauseRestartButton:update(dt)
    pauseQuitButton:update(dt)
  else
    local steps = math.max(1, math.ceil(dt / maxStep))
    local step = dt / steps
    for _ = 1, steps do
      timer = timer + step
      if timer >= self:getLevelLength() then
        self:win()
        return
      end
      if #listOfCircles == 0 and timer > 0.2 then self:spawnNote() end
      circle:update(step)
      if isFailed then return end
    end
  end
end

function maingame:spawnNote()
  local x
  local speed
  if (levelIndex == 1) then
    if (notesPassed%2==0) then
      x = math.random(2,5)
      speed = 1000
    else
      x = math.random(-5,-2)
      speed = -1000
    end
    createCircle(x, speed)
  elseif (levelIndex == 2) then
    if (math.random() < 0.5) then
      x = math.random(2,5)
      speed = 1150
    else
      x = math.random(-5,-2)
      speed = -1150
    end
    createCircle(-x, speed)
  elseif (levelIndex == 3) then
    x = math.random(2,5)
    if (math.random() < 0.5) then
      x = x*-1
    end
    createCircle(x, -1300)
  elseif (levelIndex == 4) then
    x = math.random(3,5)
    if (math.random() < 0.5) then
      x = x*-1
    end
    if (math.random() < 0.5) then
      createCircle(x, 1700)
    else
      createCircle(x, -1700)
    end
  end
end

function maingame:win()
  isWin = true
  timer = self:getLevelLength()
  listOfCircles = {}
  pauseLogoButton:setMainText("Win")
  pauseProgressButton:setAltText("Level Complete!")
  savemanager.highscores.levelScore[levelIndex] = 100
  savemanager:saveHighscores()
  if (levelIndex == 1) then
    Levels1Button:setAltText("100%")
  elseif (levelIndex == 2) then
    Levels2Button:setAltText("100%")
  elseif (levelIndex == 3) then
    Levels3Button:setAltText("100%")
  elseif (levelIndex == 4) then
    Levels4Button:setAltText("100%")
  end
end

function maingame:draw()
  maingame:LayoutUI()
  circle:draw()
  maingame:progressBar()
  if isWin then
    maingame:winScreen()
    cursor:draw()
  elseif isFailed then
    maingame:failedScreen()
    cursor:draw()
  elseif isPause then
    maingame:pauseScreen()
    cursor:draw()
  end
end

function maingame:LayoutUI()
  love.graphics.setColor(White)
  love.graphics.draw(gameBG, 0, 0)
  love.graphics.setColor(0, 0, 0, 0.25)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  love.graphics.setColor(Dark)
  love.graphics.setLineWidth(345)
  love.graphics.circle("line", gw/2, gh/2, 325)
  love.graphics.setColor(Player1Color)
  love.graphics.arc("line", "open", gw/2, gh/2, 325, -0.15, 0.15)
  love.graphics.setColor(Player2Color)
  love.graphics.arc("line", "open", gw/2, gh/2, 325, -0.15+math.pi, 0.15+math.pi)
  love.graphics.setColor(White)
  love.graphics.setLineWidth(9)
  love.graphics.circle("line", gw/2, gh/2, 500)
  love.graphics.circle("line", gw/2, gh/2, 150)
end

function maingame:mousepressed(x, y, button)
  if self:isPlaying() then
    local note = listOfCircles[1]
    if not note or (button ~= 1 and button ~= 2) then return end

    -- Judge the note at the angle the player saw on the last frame.
    local angle = math.abs(note.angle)
    if angle >= circle.hitStart and angle <= circle.hitEnd then
      local expectedButton = note.pos > 0 and 1 or 2
      if button == expectedButton then
        table.remove(listOfCircles, 1)
        notesPassed = notesPassed + 1
        circlehitsound:play()
      else
        self:fail()
      end
    elseif angle > circle.earlyStart then
      self:fail()
    end
  elseif isWin then
    pauseRestartButton:mousepressed(x, y, button)
    pauseQuitButton:mousepressed(x, y, button)
  elseif isFailed then
    pauseRestartButton:mousepressed(x, y, button)
    pauseQuitButton:mousepressed(x, y, button)
  elseif isPause then
    pauseContinueButton:mousepressed(x, y, button)
    pauseRestartButton:mousepressed(x, y, button)
    pauseQuitButton:mousepressed(x, y, button)
  end
end

function maingame:pauseScreen()
  love.graphics.setColor(0, 0, 0, 0.55)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  pauseLogoButton:draw()
  pauseContinueButton:draw()
  pauseRestartButton:draw()
  pauseQuitButton:draw()
end

function maingame:failedScreen()
  love.graphics.setColor(0, 0, 0, 0.55)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  pauseProgressButton:setMainText(math.floor(timer/maingame:getLevelLength()*100) .. "%")
  pauseLogoButton:draw()
  pauseProgressButton:draw()
  pauseRestartButton:draw()
  pauseQuitButton:draw()
end

function maingame:winScreen()
  love.graphics.setColor(0, 0, 0, 0.55)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  pauseProgressButton:setMainText(math.floor(timer/maingame:getLevelLength()*100) .. "%")
  pauseLogoButton:draw()
  pauseProgressButton:draw()
  pauseRestartButton:draw()
  pauseQuitButton:draw()
end

function maingame:progressBar()
  love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
  love.graphics.rectangle("fill", 0, gh-10, gw, 10)
  love.graphics.setColor(0.95, 0.95, 0.95, 1)
  love.graphics.rectangle("fill", 0, gh-10, gw*(timer/maingame:getLevelLength()), 10)
end

function maingame:isPlaying()
  return not isFailed and not isPause and not isWin
end

function maingame:keypressed(key)
  if key == "r" and (isFailed or isPause) then
    self:restart()
  elseif key == "escape" and not isFailed and not isWin then
    self:pause()
  elseif self:isPlaying() then
    if key == "a" or key == "f" then self:mousepressed(mx, my, 1) end
    if key == "d" or key == "j" then self:mousepressed(mx, my, 2) end
  end
end

function maingame:loadLevel(index)
  math.randomseed(os.time())
  levelIndex = index
  gamemusic = levelSongs[levelIndex]
  gamemusic:setVolume(volumeValue * 0.001)
  maingame:restart()
  gameBG = levelBGs[levelIndex]
end

function maingame:pause()
  pauseLogoButton:setMainText("Paused")
  isPause = not isPause
  if (isPause) then
    gamemusic:pause()
  else
    gamemusic:play()
  end
end

function maingame:fail()
  isFailed = true
  gamemusic:stop()
  failsound:play()
  pauseLogoButton:setMainText("Failed")
  if (math.floor(timer/maingame:getLevelLength()*100) > tonumber(savemanager.highscores.levelScore[levelIndex])) then
    pauseProgressButton:setAltText("New highscore")
    savemanager.highscores.levelScore[levelIndex] = math.floor(timer/maingame:getLevelLength()*100)
    savemanager:saveHighscores()
    if (levelIndex == 1) then
      Levels1Button:setAltText(math.floor(timer/maingame:getLevelLength()*100) .. "%")
    elseif (levelIndex == 2) then
      Levels2Button:setAltText(math.floor(timer/maingame:getLevelLength()*100) .. "%")
    elseif (levelIndex == 3) then
      Levels3Button:setAltText(math.floor(timer/maingame:getLevelLength()*100) .. "%")
    elseif (levelIndex == 4) then
      Levels4Button:setAltText(math.floor(timer/maingame:getLevelLength()*100) .. "%")
    end
  else
    pauseProgressButton:setAltText("")
  end
end

function maingame:restart()
  timer = 0
  isPause = false
  isFailed = false
  isWin = false
  notesPassed = 0
  listOfCircles = {}
  gamemusic:stop()
  gamemusic:play()
end

function maingame:endLevel()
  statemanager:changeState("menu")
  gamemusic:stop()
  menumusic:play()
end

function maingame:getLevelName()
  if (levelIndex == 1) then
    return "Super"
  elseif (levelIndex == 2) then
    return "Hyper"
  elseif (levelIndex == 3) then
    return "Ultra"
  elseif (levelIndex == 4) then
    return "Extreme"
  end
end

function maingame:getLevelLength()
  if (levelIndex == 1) then
    return 141
  elseif (levelIndex == 2) then
    return 174
  elseif (levelIndex == 3) then
    return 136
  elseif (levelIndex == 4) then
    return 123
  end
end


return maingame
