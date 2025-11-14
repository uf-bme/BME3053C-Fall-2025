-- Minimal LÖVE example: draws a movable square and a message.
function love.load()
  love.window.setTitle("Pong - LÖVE")
  width, height = 800, 600
  love.window.setMode(width, height)

  math.randomseed(os.time())

  fontSmall = love.graphics.newFont(14)
  fontLarge = love.graphics.newFont(48)
  love.graphics.setFont(fontSmall)

  paddle = { w = 12, h = 90, speed = 360 }
  p1 = { x = 30, y = height/2 - paddle.h/2, score = 0 }
  p2 = { x = width - 30 - paddle.w, y = height/2 - paddle.h/2, score = 0 }

  ball = { x = width/2, y = height/2, r = 8, speed = 280, vx = 0, vy = 0 }
  speedMax = 720
  ball.color = { r = 1, g = 1, b = 1 }

  gameState = "serve"
  servingPlayer = (math.random() < 0.5) and 1 or 2
  paused = false

  function resetBall(toPlayer)
    ball.x, ball.y = width/2, height/2
    local angle = (math.random() * 0.6 - 0.3) -- ~[-17°, 17°]
    local dir = (toPlayer == 1) and -1 or 1
    ball.vx = dir * ball.speed * math.cos(angle)
    ball.vy = ball.speed * math.sin(angle)
  end

  resetBall(servingPlayer)
end

local function aabb(ax, ay, aw, ah, bx, by, bw, bh)
  return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function randomBrightColor()
  local function rnd()
    return 0.35 + 0.65 * math.random()
  end
  return { r = rnd(), g = rnd(), b = rnd() }
end

function love.update(dt)
  if paused then return end

  local pSpeed = paddle.speed * dt

  if love.keyboard.isDown("w") then p1.y = p1.y - pSpeed end
  if love.keyboard.isDown("s") then p1.y = p1.y + pSpeed end
  if love.keyboard.isDown("up") then p2.y = p2.y - pSpeed end
  if love.keyboard.isDown("down") then p2.y = p2.y + pSpeed end

  p1.y = clamp(p1.y, 0, height - paddle.h)
  p2.y = clamp(p2.y, 0, height - paddle.h)

  if gameState == "serve" then
    ball.x, ball.y = width/2, height/2
    return
  end

  if gameState ~= "play" then return end

  ball.x = ball.x + ball.vx * dt
  ball.y = ball.y + ball.vy * dt

  if ball.y - ball.r <= 0 then
    ball.y = ball.r
    ball.vy = -ball.vy
    ball.color = randomBrightColor()
  elseif ball.y + ball.r >= height then
    ball.y = height - ball.r
    ball.vy = -ball.vy
    ball.color = randomBrightColor()
  end

  local bx, by, bw, bh = ball.x - ball.r, ball.y - ball.r, ball.r * 2, ball.r * 2

  if aabb(bx, by, bw, bh, p1.x, p1.y, paddle.w, paddle.h) and ball.vx < 0 then
    ball.x = p1.x + paddle.w + ball.r
    ball.vx = -ball.vx
    ball.speed = math.min(speedMax, ball.speed * 1.05)
    local offset = ((ball.y - p1.y) / paddle.h - 0.5) * 2
    ball.vy = offset * ball.speed
    local sign = (ball.vx < 0) and -1 or 1
    ball.vx = sign * math.sqrt(math.max(0, ball.speed^2 - ball.vy^2))
    ball.color = randomBrightColor()
  elseif aabb(bx, by, bw, bh, p2.x, p2.y, paddle.w, paddle.h) and ball.vx > 0 then
    ball.x = p2.x - ball.r
    ball.vx = -ball.vx
    ball.speed = math.min(speedMax, ball.speed * 1.05)
    local offset = ((ball.y - p2.y) / paddle.h - 0.5) * 2
    ball.vy = offset * ball.speed
    local sign = (ball.vx < 0) and -1 or 1
    ball.vx = sign * math.sqrt(math.max(0, ball.speed^2 - ball.vy^2))
    ball.color = randomBrightColor()
  end

  if ball.x + ball.r < 0 then
    p2.score = p2.score + 1
    ball.speed = 280
    servingPlayer = 1
    gameState = "serve"
    resetBall(servingPlayer)
  elseif ball.x - ball.r > width then
    p1.score = p1.score + 1
    ball.speed = 280
    servingPlayer = 2
    gameState = "serve"
    resetBall(servingPlayer)
  end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "p" then paused = not paused end
  if key == "space" then
    if gameState == "serve" then
      gameState = "play"
    end
  end
end

function love.draw()
  love.graphics.setFont(fontLarge)
  love.graphics.printf("PONG", 0, 30, width, "center")

  love.graphics.setFont(fontSmall)
  for y = 0, height, 20 do
    love.graphics.rectangle("fill", width/2 - 2, y, 4, 10)
  end

  love.graphics.setFont(fontLarge)
  love.graphics.print(p1.score, width/2 - 80, 80)
  love.graphics.print(p2.score, width/2 + 50, 80)

  love.graphics.setFont(fontSmall)
  local info = "P1: W/S   P2: Up/Down   Space: Serve   P: Pause"
  love.graphics.printf(info, 0, height - 30, width, "center")

  love.graphics.rectangle("fill", p1.x, p1.y, paddle.w, paddle.h)
  love.graphics.rectangle("fill", p2.x, p2.y, paddle.w, paddle.h)
  love.graphics.setColor(ball.color.r, ball.color.g, ball.color.b)
  love.graphics.circle("fill", ball.x, ball.y, ball.r)
  love.graphics.setColor(1, 1, 1)

  if gameState == "serve" then
    local msg = (servingPlayer == 1) and "Player 1 serve" or "Player 2 serve"
    love.graphics.printf(msg .. " — press Space", 0, height/2 - 40, width, "center")
  end
  if paused then
    love.graphics.printf("PAUSED", 0, height/2 + 10, width, "center")
  end
end