local Engine = require("engine")
local game
local lastSavedBest = 0

function love.load()
  love.window.setMode(600, 400, { resizable = false })
  love.window.setTitle("GX Space Shooter — Lua / LÖVE2D")
  local saved = tonumber(love.filesystem.read("recorde.txt")) or 0
  lastSavedBest = math.max(0, math.floor(saved))
  game = Engine.new(nil, lastSavedBest)
end

function love.update(dt)
  game:update(dt, {
    left = love.keyboard.isDown("left", "a"),
    right = love.keyboard.isDown("right", "d"),
    shoot = love.keyboard.isDown("space"),
  })
  if game.bestScore > lastSavedBest then
    local written = love.filesystem.write("recorde.txt", tostring(game.bestScore))
    if written then lastSavedBest = game.bestScore end
  end
end

function love.keypressed(key)
  if key == "p" and not game.gameOver then game.paused = not game.paused end
  if key == "r" and game.gameOver then game:reset() end
  if key == "s" then game:activateShield() end
end

function love.draw()
  love.graphics.clear(0.043, 0.063, 0.125)
  local p = game.player
  love.graphics.setColor(0.376, 0.647, 0.98)
  love.graphics.polygon("fill", p.x + p.w/2, p.y - 8, p.x, p.y + p.h, p.x + p.w, p.y + p.h)
  if game.shieldTime > 0 then
    love.graphics.setColor(0.28, 0.87, 0.9, 0.88)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", p.x + p.w/2, p.y + p.h/2, 31)
    love.graphics.setLineWidth(1)
  end

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
  love.graphics.print("Recorde: " .. game.bestScore, 130, 12)
  love.graphics.print("Nivel: " .. game.level, 282, 12)
  love.graphics.print("Vidas: " .. game.lives, 510, 12)
  love.graphics.print("Escudos: " .. game.shieldCharges, 12, 34)
  if game.combo > 1 then
    love.graphics.setColor(1, 0.82, 0.22)
    love.graphics.print("Combo x" .. game.combo .. " (" .. string.format("%.1f", game.comboTime) .. "s)", 328, 34)
    love.graphics.setColor(1, 1, 1)
  end
  if game.shieldTime > 0 then
    love.graphics.print(string.format("Protegido: %.1fs", game.shieldTime), 130, 34)
  end
  love.graphics.print("A/D ou setas mover | Espaco atirar | S escudo | P pausa", 12, 378)
  if game.gameOver then
    love.graphics.printf("FIM DE JOGO — pressione R para reiniciar", 0, 180, 600, "center")
  elseif game.paused then
    love.graphics.printf("PAUSADO", 0, 180, 600, "center")
  end
end
