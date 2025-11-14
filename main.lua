function love.load()
  love.window.setTitle("Hello from Codespaces + LÖVE")
  width, height = 800, 600
  love.window.setMode(width, height)
  msg = "It works! 🚀  Use arrow keys to move the box."
  player = { x = 100, y = 100, s = 40, v = 200 }
end

function love.update(dt)
  if love.keyboard.isDown("d") then player.x = player.x + player.v * dt end
  if love.keyboard.isDown("a")  then player.x = player.x - player.v * dt end
  if love.keyboard.isDown("s")  then player.y = player.y + player.v * dt end
  if love.keyboard.isDown("w")    then player.y = player.y - player.v * dt end
end

function love.draw()
  love.graphics.print(msg, 20, 20)
  love.graphics.rectangle("fill", player.x, player.y, player.s, player.s)
end