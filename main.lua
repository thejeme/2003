require 'lib/simpleScale'
local display = require 'lib/display'

require 'globals'
require 'colors'

require 'objects/cursor'

require 'managers/statemanager'
require 'managers/savemanager'

webBuild = love.system.getOS() == "Web"
for _, value in ipairs(arg or {}) do
  if value == "--web" then webBuild = true end
end
local discordRPC
if love.system.getOS() == "Windows" and not webBuild then
  local ok, rpc = pcall(require, "lib/discordRPC")
  if ok then discordRPC = rpc end
end
local pointerMode = "mouse"
local activePad
local appId = require 'applicationId'

function love.load()
  savemanager:load()
  cursor:load()
  volumeValue = savemanager.settings.volume or 100
  display.load(savemanager.settings)
  statemanager:load()
  mx, my = simpleScale.toGame(love.mouse.getPosition())
  love.mouse.setVisible(false)

  if discordRPC then discordRPC.initialize(appId, true) end
  now = os.time(os.date("*t"))
  nextPresenceUpdate = 0
end

function discordApplyPresence()
  if statemanager:getState() == "game" then
    detailsNow = "Playing: " .. maingame:getLevelName()
  else
    detailsNow = "In Mainmenu"
  end
  stateNow = ""
  presence = {
    largeImageKey = "icon",
    largeImageText = "2003",
    details = detailsNow,
    state = stateNow,
    startTimestamp = now,
  }

  return presence
end

function love.update(dt)
  if pointerMode == "pad" and activePad and activePad:isConnected() then
    local x, y = activePad:getGamepadAxis("leftx"), activePad:getGamepadAxis("lefty")
    if math.abs(x) > 0.15 then mx = math.max(0, math.min(gw, mx + x * dt * 1100)) end
    if math.abs(y) > 0.15 then my = math.max(0, math.min(gh, my + y * dt * 1100)) end
  end
  if pointerMode == "mouse" then
    mx, my = simpleScale.toGame(love.mouse.getPosition())
  end

  statemanager:update(dt)

  if discordRPC and nextPresenceUpdate < love.timer.getTime() then
      discordRPC.updatePresence(discordApplyPresence())
      nextPresenceUpdate = love.timer.getTime() + 2.0
  end
  if discordRPC then discordRPC.runCallbacks() end
end

function love.draw()
	simpleScale.set()
    statemanager:draw()
  simpleScale.unSet()
end

function love.mousemoved(x, y, dx, dy, istouch)
  if not istouch and (dx ~= 0 or dy ~= 0) then pointerMode = "mouse" end
end

function love.resize() simpleScale.resizeUpdate() end

function love.mousepressed(x, y, button, istouch)
  if istouch then return end
  pointerMode = "mouse"
  mx, my = simpleScale.toGame(x, y)
  statemanager:mousepressed(mx, my, button)
end

function love.keypressed(key)
  statemanager:keypressed(key)
end

function love.quit()
  if discordRPC then discordRPC.shutdown() end
end

function love.gamepadaxis(pad, axis, value)
  if (axis == "leftx" or axis == "lefty") and math.abs(value) > 0.15 then
    activePad, pointerMode = pad, "pad"
  end
end

function love.gamepadpressed(pad, button)
  activePad, pointerMode = pad, "pad"
  if button == "start" or button == "b" then
    statemanager:keypressed("escape")
  elseif button == "leftshoulder" or button == "dpleft" then
    statemanager:keypressed("a")
  elseif button == "rightshoulder" or button == "dpright" then
    statemanager:keypressed("d")
  elseif button == "a" or button == "x" then
    statemanager:mousepressed(mx, my, button == "a" and 1 or 2)
  end
end

function love.touchpressed(id, x, y)
  pointerMode = "touch"
  mx, my = simpleScale.toGame(x, y)
  if #love.touch.getTouches() > 1 then
    statemanager:keypressed("escape")
  elseif statemanager:getState() == "game" and maingame:isPlaying() then
    statemanager:mousepressed(mx, my, mx < gw / 2 and 1 or 2)
  else
    statemanager:mousepressed(mx, my, 1)
  end
end
