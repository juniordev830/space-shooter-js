local Engine = require("engine")
local game

function love.load()
  love.window.setMode(600, 400, { resizable = false })
  love.window.setTitle("GX Space Shooter — Lua / LÖVE2D")
  game = Engine.new()
end

function love.update(dt)
  game:update(dt, {
    left = love.keyboard.isDown("left", "a"),
    right = love.keyboard.isDown("right", "d"),
    shoot = love.keyboard.isDown("space"),
  })
end

function love.keypressed(key)
  if key == "p" then game.paused = not game.paused end
  if key == "r" and game.gameOver then game:reset() end
end

function love.draw()
  love.graphics.clear(0.043, 0.063, 0.125)
  local p = game.player
  love.graphics.setColor(0.376, 0.647, 0.98)
  love.graphics.polygon("fill", p.x + p.w/2, p.y - 8, p.x, p.y + p.h, p.x + p.w, p.y + p.h)

  love.graphics.setColor(0.98, 0.8, 0.08)
  for _, b in ipairs(game.bullets) do
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
  end
  love.graphics.setColor(0.97, 0.44, 0.44)
  for _, e in ipairs(game.enemies) do
    love.graphics.rectangle("fill", e.x, e.y, e.w, e.h)
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Pontos: " .. game.score, 12, 12)
  love.graphics.print("Vidas: " .. game.lives, 520, 12)
  love.graphics.print("Setas/A/D mover | Espaço atirar | P pausa", 12, 378)
  if game.gameOver then
    love.graphics.printf("FIM DE JOGO — pressione R para reiniciar", 0, 180, 600, "center")
  elseif game.paused then
    love.graphics.printf("PAUSADO", 0, 180, 600, "center")
  end
end
