const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");
const { GameEngine, intersects, attachPointerControl } = require("./game.js");

test("pointer controls handle simultaneous touches and cancellation", () => {
  const handlers = {};
  const captured = [];
  const button = {
    addEventListener(name, callback) { handlers[name] = callback; },
    setPointerCapture(id) { captured.push(id); }
  };
  const active = new Set();
  attachPointerControl(button, active);
  handlers.pointerdown({ pointerId: 1, preventDefault() {} });
  handlers.pointerdown({ pointerId: 2, preventDefault() {} });
  assert.deepEqual(captured, [1, 2]);
  handlers.pointerup({ pointerId: 1 });
  assert.equal(active.has(2), true);
  handlers.pointercancel({ pointerId: 2 });
  assert.equal(active.size, 0);
  attachPointerControl(null, active);
});

test("browser entry point connects the on-screen controls to the game", () => {
  const positions = [];
  const context = {
    clearRect() {}, fillRect() {}, beginPath() {}, closePath() {}, fill() {}, lineTo() {}, fillText() {},
    moveTo(x) { positions.push(x); }
  };
  const buttons = {};
  for (const name of ["left", "right", "shoot", "restart"]) {
    buttons[`control-${name}`] = {
      handlers: {},
      addEventListener(event, callback) { this.handlers[event] = callback; },
      setPointerCapture() {}
    };
  }
  const canvas = { width: 600, height: 400, getContext: () => context };
  const document = { getElementById: id => id === "gameCanvas" ? canvas : buttons[id] };
  const frames = [];
  const window = { addEventListener() {}, requestAnimationFrame: callback => frames.push(callback) };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "game.js"), "utf8"), { window, document });
  frames.shift()(1000);
  buttons["control-left"].handlers.pointerdown({ pointerId: 1, preventDefault() {} });
  frames.shift()(1050);
  assert.ok(positions[1] < positions[0]);
  buttons["control-left"].handlers.pointerup({ pointerId: 1 });
  frames.shift()(1100);
  assert.equal(positions[2], positions[1]);
  buttons["control-restart"].handlers.click();
  frames.shift()(1150);
  assert.equal(positions[3], positions[0]);
});

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

test("pause freezes simulation until resumed", () => {
  const game = new GameEngine({ random: () => 0.5 });
  const initialX = game.player.x;
  game.setPaused(true);
  game.update(1000, { right: true, shoot: true });
  assert.equal(game.player.x, initialX);
  assert.equal(game.bullets.length, 0);
  assert.equal(game.paused, true);

  game.togglePaused();
  game.update(16, { right: true });
  assert.ok(game.player.x > initialX);
  assert.equal(game.paused, false);
});

test("shooting creates a bullet and respects cooldown", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.update(16, { shoot: true });
  game.update(16, { shoot: true });
  assert.equal(game.bullets.length, 1);
  for (let i = 0; i < 5; i++) game.update(50, { shoot: true });
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

test("enemy collision with player removes enemy and costs one life only", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.enemies.push({
    x: game.player.x + 5,
    y: game.player.y + 5,
    width: 30,
    height: 22,
    speed: 0
  });

  game.update(16);
  assert.equal(game.lives, 2);
  assert.equal(game.enemies.length, 0);

  game.update(16);
  assert.equal(game.lives, 2);
});

test("player collision ends game at zero lives", () => {
  const game = new GameEngine({ random: () => 0.5 });
  game.lives = 1;
  game.enemies.push({
    x: game.player.x,
    y: game.player.y,
    width: 30,
    height: 22,
    speed: 0
  });

  game.update(16);
  assert.equal(game.lives, 0);
  assert.equal(game.gameOver, true);
  game.update(16);
  assert.equal(game.lives, 0);
});
