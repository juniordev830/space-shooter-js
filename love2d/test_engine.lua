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

-- Level progression, new shield charge and in-session high score.
game = Engine.new(deterministic, 120)
assert(game.bestScore == 120)
game.score = 90
table.insert(game.bullets, { x = 101, y = 100, w = 4, h = 12, speed = 0 })
table.insert(game.enemies, { x = 100, y = 99, w = 30, h = 22, speed = 0 })
game:update(0.016)
assert(game.score == 100 and game.level == 2)
assert(game.shieldCharges == 2, "a new level should grant one shield charge")
assert(game.bestScore == 120, "the saved record should not decrease")

-- A shield absorbs direct enemy contact for two seconds.
assert(game:activateShield() == true)
assert(game.shieldCharges == 1 and game.shieldTime > 0)
assert(game:activateShield() == false, "active shield must not consume another charge")
table.insert(game.enemies, {
  x = game.player.x, y = game.player.y, w = 30, h = 22, speed = 0,
})
local remaining = game.lives
game:update(0.016)
assert(game.lives == remaining and #game.enemies == 0, "shield must absorb contact")
assert(game.shieldTime < 2, "shield timer must decrease")

-- Pause and game-over prevent shield activation.
game.paused = true
assert(game:activateShield() == false)
game.paused = false
for _ = 1, 42 do game:update(0.05) end
assert(game.shieldTime == 0, "shield should expire")
table.insert(game.enemies, {
  x = game.player.x, y = game.player.y, w = 30, h = 22, speed = 0,
})
game:update(0.016)
assert(game.lives == remaining - 1, "collision must damage when shield expired")

-- Missing an enemy still costs a life even with shield.
game.shieldTime = 1
table.insert(game.enemies, { x = 0, y = 401, w = 30, h = 22, speed = 0 })
remaining = game.lives
game:update(0.016)
assert(game.lives == remaining - 1)

-- Reset preserves best score while restoring game resources.
game.bestScore = 200
game:reset()
assert(game.bestScore == 200)
assert(game.level == 1 and game.shieldCharges == 1 and game.shieldTime == 0)
assert(game.lives == 3 and game.score == 0)

print("Lua game tests passed")
