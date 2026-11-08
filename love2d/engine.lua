local Engine = {}
Engine.__index = Engine

local function overlaps(a, b)
  return a.x < b.x + b.w and a.x + a.w > b.x
    and a.y < b.y + b.h and a.y + a.h > b.y
end

function Engine.new(random)
  local self = setmetatable({
    width = 600,
    height = 400,
    random = random or math.random,
  }, Engine)
  self:reset()
  return self
end

function Engine:reset()
  self.player = { x = 280, y = 358, w = 40, h = 24, speed = 280 }
  self.bullets = {}
  self.enemies = {}
  self.score = 0
  self.lives = 3
  self.gameOver = false
  self.paused = false
  self.spawnTime = 0
  self.fireCooldown = 0
end

function Engine:update(dt, input)
  if self.gameOver or self.paused then return end
  input = input or {}
  dt = math.max(0, math.min(dt or 0, 0.05))
  self.spawnTime = self.spawnTime + dt
  self.fireCooldown = math.max(0, self.fireCooldown - dt)

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

  if self.spawnTime >= 0.85 then
    self.spawnTime = self.spawnTime - 0.85
    table.insert(self.enemies, {
      x = self.random() * (self.width - 30), y = -28,
      w = 30, h = 22, speed = 85 + math.min(self.score, 300) * 0.15,
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
          self.score = self.score + 10
          break
        end
      end
    end
  end

  for i = #self.enemies, 1, -1 do
    local enemy = self.enemies[i]
    if overlaps(enemy, p) or enemy.y > self.height then
      table.remove(self.enemies, i)
      self.lives = self.lives - 1
    end
  end
  if self.lives <= 0 then
    self.lives = 0
    self.gameOver = true
  end
end

return Engine
