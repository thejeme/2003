local circletrail = require 'objects/circletrail'

circle = {earlyStart = math.pi * 0.84, hitStart = math.pi * 0.93, hitEnd = math.pi * 1.07}
listOfCircles = {}

function createCircle(pos, speed)
  local c = {}
  if (pos > 0) then
    c.pos = 150+50*pos
    c.r = 255 / 255
    c.g = 118 / 255
    c.b = 117 / 255
  else
    c.pos = -150+50*pos
    c.r = 9 / 255
    c.g = 132 / 255
    c.b = 227 / 255
  end
  c.x, c.y = gw / 2 + c.pos, gh / 2
  c.speed = speed
  c.angle = 0
  c.circletrail = circletrail.new()
  table.insert(listOfCircles, c)
end

function circle:update(dt)
  local missed = false
  for i = #listOfCircles, 1, -1 do
    local v = listOfCircles[i]
    v.angle = v.angle + (v.speed / v.pos * dt)
    v.x = gw/2+math.cos(v.angle)*v.pos
    v.y = gh/2+math.sin(v.angle)*v.pos
    if (math.abs(v.angle) > self.hitEnd) then
      table.remove(listOfCircles, i)
      missed = true
    else
      v.circletrail:update(dt, v.x, v.y)
    end
  end
  if missed then maingame:fail() end
end

function circle:draw()
  for i, v in ipairs(listOfCircles) do
    v.circletrail:draw(v.r, v.g, v.b)
    love.graphics.setColor(White)
    love.graphics.circle('fill', v.x, v.y, 20, 120)
    love.graphics.setColor(v.r, v.g, v.b, 1)
    love.graphics.setLineWidth(8)
    love.graphics.circle('line', v.x, v.y, 20, 120)
  end
end

return circle
