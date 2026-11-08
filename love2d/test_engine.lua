package.path = "love2d/?.lua;" .. package.path
local Engine = require("engine")

local function deterministic() return 0.5 end
local game = Engine.new(deterministic)
assert(game.score == 0 and game.lives == 3)
assert(game.player.x == 280)

game:update(0.05, { left = true, shoot = true })
assert(game.player.x < 280)
assert(#game.bullets == 1)
game:update(0.05, { shoot = true })
assert(#game.bullets == 1, "shooting must respect the cooldown")

game.player.x = -100
game:update(0.05, { left = true })
assert(game.player.x == 0, "player must remain inside the canvas")
game.player.x = 999
game:update(0.05, { right = true })
assert(game.player.x == 560)

game = Engine.new(deterministic)
table.insert(game.bullets, { x = 101, y = 100, w = 4, h = 12, speed = 0 })
table.insert(game.enemies, { x = 100, y = 99, w = 30, h = 22, speed = 0 })
game:update(0.016)
assert(game.score == 10 and #game.bullets == 0 and #game.enemies == 0)

game = Engine.new(deterministic)
game.enemies = {
  { x = 10, y = 401, w = 30, h = 22, speed = 0 },
  { x = 50, y = 401, w = 30, h = 22, speed = 0 },
  { x = 90, y = 401, w = 30, h = 22, speed = 0 },
}
game:update(0.016)
assert(game.gameOver and game.lives == 0)
game:reset()
assert(not game.gameOver and game.lives == 3)

game.paused = true
local x = game.player.x
game:update(0.05, { left = true })
assert(game.player.x == x, "pause must freeze updates")
print("Lua game tests passed")
