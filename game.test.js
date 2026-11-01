const test = require("node:test");
const assert = require("node:assert/strict");
const { GameEngine, intersects } = require("./game.js");

test("player stays within the canvas bounds", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.update(50, { left: true });
  game.player.x = 1;
  game.update(50, { left: true });
  assert.equal(game.player.x, 0);
  game.player.x = 599;
  game.update(50, { right: true });
  assert.equal(game.player.x, 560);
});

test("shooting creates a bullet and respects cooldown", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.update(16, { shoot: true });
  game.update(16, { shoot: true });
  assert.equal(game.bullets.length, 1);
  game.update(250, { shoot: true });
  assert.equal(game.bullets.length, 2);
});

test("bullet and enemy collision awards points", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.bullets.push({ x: 100, y: 100, width: 4, height: 12, speed: 0 });
  game.enemies.push({ x: 99, y: 99, width: 30, height: 22, speed: 0 });
  game.update(16);
  assert.equal(game.score, 10);
  assert.equal(game.enemies.length, 0);
  assert.equal(game.bullets.length, 0);
});

test("missing three enemies ends the game and reset restores state", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.enemies = [
    { x: 10, y: 401, width: 30, height: 22, speed: 0 },
    { x: 50, y: 401, width: 30, height: 22, speed: 0 },
    { x: 90, y: 401, width: 30, height: 22, speed: 0 }
  ];
  game.update(16);
  assert.equal(game.lives, 0);
  assert.equal(game.gameOver, true);
  game.reset();
  assert.equal(game.lives, 3);
  assert.equal(game.gameOver, false);
  assert.equal(game.score, 0);
});

test("rectangle collision helper detects overlap only", () => {
  assert.equal(intersects({ x: 0, y: 0, width: 10, height: 10 }, { x: 9, y: 9, width: 10, height: 10 }), true);
  assert.equal(intersects({ x: 0, y: 0, width: 10, height: 10 }, { x: 10, y: 10, width: 10, height: 10 }), false);
});
