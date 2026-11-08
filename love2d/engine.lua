local Engine = {}
Engine.__index = Engine

local function overlaps(a, b)
  return a.x < b.x + b.w and a.x + a.w > b.x
    and a.y < b.y + b.h and a.y + a.h > b.y
end

function Engine.new(random, savedBest)
  local self = setmetatable({
    width = 600,
    height = 400,
    random = random or math.random,
    bestScore = math.max(0, math.floor(tonumber(savedBest) or 0)),
  }, Engine)
  self:reset()
  return self
end

function Engine:reset()
  self.bestScore = math.max(self.bestScore or 0, self.score or 0)
  self.player = { x = 280, y = 358, w = 40, h = 24, speed = 280 }
  self.bullets = {}
  self.enemies = {}
  self.score = 0
  self.combo = 0
  self.comboTime = 0
  self.level = 1
  self.lives = 3
  self.shieldCharges = 1
  self.shieldTime = 0
  self.gameOver = false
  self.paused = false
  self.spawnTime = 0
  self.fireCooldown = 0
end

function Engine:activateShield()
  if self.gameOver or self.paused or self.shieldCharges == 0 or self.shieldTime > 0 then
    return false
  end
  self.shieldCharges = self.shieldCharges - 1
  self.shieldTime = 2.0
  return true
end

function Engine:update(dt, input)
  if self.gameOver or self.paused then return end
  input = input or {}
  -- Bound physics steps, even after a window was suspended.
  dt = math.max(0, math.min(tonumber(dt) or 0, 0.05))
  self.shieldTime = math.max(0, self.shieldTime - dt)
  self.spawnTime = self.spawnTime + dt
  self.fireCooldown = math.max(0, self.fireCooldown - dt)
  self.comboTime = math.max(0, self.comboTime - dt)
  if self.comboTime == 0 then self.combo = 0 end

  local direction = (input.right and 1 or 0) - (input.left and 1 or 0)
  local p = self.player
  p.x = math.max(0, math.min(self.width - p.w, p.x + direction * p.speed * dt))

  if input.shoot and self.fireCooldown <= 0 then
    table.insert(self.bullets, {
      x = p.x + p.w / 2 - 2, y = p.y - 10,
      w = 4, h = 12, speed = 420,
    })
    self.fireCooldown = 0.24
  end

  -- Every 100 points increases the level and enemy spawn rate.
  local spawnInterval = math.max(0.35, 0.85 - 0.05 * (self.level - 1))
  if self.spawnTime >= spawnInterval then
    self.spawnTime = self.spawnTime - spawnInterval
    table.insert(self.enemies, {
      x = self.random() * (self.width - 30), y = -28,
      w = 30, h = 22,
      speed = 85 + math.min(self.score, 300) * 0.15 + (self.level - 1) * 8,
    })
  end

  for _, bullet in ipairs(self.bullets) do
    bullet.y = bullet.y - bullet.speed * dt
  end
  for _, enemy in ipairs(self.enemies) do
    enemy.y = enemy.y + enemy.speed * dt
  end

  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    if bullet.y + bullet.h < 0 then
      table.remove(self.bullets, i)
    else
      for j = #self.enemies, 1, -1 do
        if overlaps(bullet, self.enemies[j]) then
          table.remove(self.enemies, j)
          table.remove(self.bullets, i)
          -- Chain hits within three seconds for up to 5x points.
          self.combo = math.min(5, self.combo + 1)
          self.comboTime = 3.0
          self.score = self.score + 10 * self.combo
          self.bestScore = math.max(self.bestScore, self.score)
          local nextLevel = math.floor(self.score / 100) + 1
          if nextLevel > self.level then
            self.shieldCharges = math.min(3, self.shieldCharges + (nextLevel - self.level))
            self.level = nextLevel
          end
          break
        end
      end
    end
  end

  for i = #self.enemies, 1, -1 do
    local enemy = self.enemies[i]
    if overlaps(enemy, p) or enemy.y > self.height then
      table.remove(self.enemies, i)
      -- A shield protects the ship from collisions, not missed enemies.
      if enemy.y > self.height or self.shieldTime <= 0 then
        self.lives = self.lives - 1
        self.combo = 0
        self.comboTime = 0
      end
    end
  end
  if self.lives <= 0 then
    self.lives = 0
    self.gameOver = true
  end
end

return Engine
