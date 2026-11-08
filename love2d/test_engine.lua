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

-- Consecutive kills reward a growing combo; idle time resets it.
game = Engine.new(deterministic)
table.insert(game.bullets, { x=101, y=100, w=4, h=12, speed=0 })
table.insert(game.bullets, { x=201, y=100, w=4, h=12, speed=0 })
table.insert(game.enemies, { x=100, y=99, w=30, h=22, speed=0 })
table.insert(game.enemies, { x=200, y=99, w=30, h=22, speed=0 })
game:update(0.016)
assert(game.score == 30 and game.combo == 2, "consecutive hits must score 10 + 20")
assert(game.bestScore == 30)
game.paused = true
game:update(10)
assert(game.combo == 2, "pause must not consume combo time")
game.paused = false
for _ = 1, 61 do game:update(0.05) end
assert(game.combo == 0 and game.comboTime == 0, "combo must expire after three seconds")
table.insert(game.bullets, { x=101, y=100, w=4, h=12, speed=0 })
table.insert(game.enemies, { x=100, y=99, w=30, h=22, speed=0 })
game:update(0.016)
assert(game.score == 40 and game.combo == 1, "new streak starts at x1")
table.insert(game.enemies, { x=0, y=401, w=30, h=22, speed=0 })
game:update(0.016)
assert(game.combo == 0, "a missed enemy breaks the streak")
game:reset()
assert(game.combo == 0 and game.comboTime == 0)

-- Every fifth kill drops a repair capsule that restores one life.
game = Engine.new(deterministic)
game.lives = 2
for n = 1, 5 do
  local px = 50 + n * 75
  table.insert(game.bullets, { x=px, y=100, w=4, h=12, speed=0 })
  table.insert(game.enemies, { x=px-1, y=99, w=30, h=22, speed=0 })
end
game:update(0.016)
assert(game.kills == 5 and #game.pickups == 1, "fifth kill must drop a repair")
assert(game.lives == 2 and #game.enemies == 0)

local capsule = game.pickups[1]
capsule.x = game.player.x
capsule.y = game.player.y
capsule.speed = 0
game:update(0.016)
assert(game.lives == 3 and #game.pickups == 0, "collecting a repair should heal")

-- Repairs cannot raise lives above 3 and must expire harmlessly.
table.insert(game.pickups, {
  x=game.player.x, y=game.player.y, w=14, h=14, speed=0,
})
game:update(0.016)
assert(game.lives == 3 and #game.pickups == 0, "life cap must hold")
table.insert(game.pickups, { x=0, y=401, w=14, h=14, speed=115 })
game:update(0.016)
assert(game.lives == 3 and #game.pickups == 0, "missed repairs are harmless")

game:reset()
assert(game.kills == 0 and #game.pickups == 0, "reset must clear drops")

print("Lua game tests passed")
