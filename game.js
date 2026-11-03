(function (root) {
  "use strict";

  const WIDTH = 600;
  const HEIGHT = 400;

  class Player {
    constructor() {
      this.width = 40;
      this.height = 24;
      this.x = (WIDTH - this.width) / 2;
      this.y = HEIGHT - 42;
      this.speed = 280;
    }
  }

  class GameEngine {
    constructor(options = {}) {
      this.width = options.width || WIDTH;
      this.height = options.height || HEIGHT;
      this.random = options.random || Math.random;
      this.reset();
    }

    reset() {
      this.player = new Player();
      this.player.x = (this.width - this.player.width) / 2;
      this.player.y = this.height - 42;
      this.bullets = [];
      this.enemies = [];
      this.score = 0;
      this.lives = 3;
      this.gameOver = false;
      this.paused = false;
      this.elapsed = 0;
      this.spawnElapsed = 0;
      this.fireCooldown = 0;
    }

    setPaused(paused) {
      this.paused = Boolean(paused);
    }

    togglePaused() {
      this.paused = !this.paused;
      return this.paused;
    }

    update(deltaMs, input = {}) {
      if (this.gameOver || this.paused) return;
      const delta = Math.max(0, Math.min(Number(deltaMs) || 0, 50)) / 1000;
      this.elapsed += delta * 1000;
      this.spawnElapsed += delta * 1000;
      this.fireCooldown = Math.max(0, this.fireCooldown - delta * 1000);

      if (input.left) this.player.x -= this.player.speed * delta;
      if (input.right) this.player.x += this.player.speed * delta;
      this.player.x = Math.max(0, Math.min(this.width - this.player.width, this.player.x));

      if (input.shoot && this.fireCooldown === 0) {
        this.bullets.push({
          x: this.player.x + this.player.width / 2 - 2,
          y: this.player.y - 10,
          width: 4,
          height: 12,
          speed: 420
        });
        this.fireCooldown = 240;
      }

      if (this.spawnElapsed >= 850) {
        this.spawnElapsed = 0;
        this.enemies.push({
          x: this.random() * (this.width - 30),
          y: -28,
          width: 30,
          height: 22,
          speed: 85 + Math.min(this.score, 300) * 0.15
        });
      }

      for (const bullet of this.bullets) bullet.y -= bullet.speed * delta;
      for (const enemy of this.enemies) enemy.y += enemy.speed * delta;

      for (let i = this.bullets.length - 1; i >= 0; i--) {
        if (this.bullets[i].y + this.bullets[i].height < 0) {
          this.bullets.splice(i, 1);
          continue;
        }
        const bullet = this.bullets[i];
        const hitIndex = this.enemies.findIndex(enemy => intersects(bullet, enemy));
        if (hitIndex !== -1) {
          this.enemies.splice(hitIndex, 1);
          this.bullets.splice(i, 1);
          this.score += 10;
        }
      }

      // An enemy that reaches the player causes damage immediately and is
      // removed, so it cannot repeatedly drain lives on subsequent frames.
      for (let i = this.enemies.length - 1; i >= 0; i--) {
        const enemy = this.enemies[i];
        if (intersects(enemy, this.player)) {
          this.enemies.splice(i, 1);
          this.lives -= 1;
          continue;
        }
        if (enemy.y > this.height) {
          this.enemies.splice(i, 1);
          this.lives -= 1;
        }
      }
      if (this.lives <= 0) {
        this.lives = 0;
        this.gameOver = true;
      }
    }
  }

  function intersects(a, b) {
    return a.x < b.x + b.width &&
      a.x + a.width > b.x &&
      a.y < b.y + b.height &&
      a.y + a.height > b.y;
  }

  function drawGame(ctx, engine) {
    ctx.clearRect(0, 0, engine.width, engine.height);
    ctx.fillStyle = "#0b1020";
    ctx.fillRect(0, 0, engine.width, engine.height);

    ctx.fillStyle = "#60a5fa";
    ctx.beginPath();
    ctx.moveTo(engine.player.x + engine.player.width / 2, engine.player.y - 8);
    ctx.lineTo(engine.player.x, engine.player.y + engine.player.height);
    ctx.lineTo(engine.player.x + engine.player.width, engine.player.y + engine.player.height);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = "#facc15";
    for (const bullet of engine.bullets) ctx.fillRect(bullet.x, bullet.y, bullet.width, bullet.height);

    ctx.fillStyle = "#f87171";
    for (const enemy of engine.enemies) {
      ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height);
      ctx.fillStyle = "#fecaca";
      ctx.fillRect(enemy.x + 5, enemy.y + 6, 5, 4);
      ctx.fillRect(enemy.x + enemy.width - 10, enemy.y + 6, 5, 4);
      ctx.fillStyle = "#f87171";
    }

    ctx.fillStyle = "#ffffff";
    ctx.font = "16px sans-serif";
    ctx.fillText("Score: " + engine.score, 12, 22);
    ctx.fillText("Lives: " + engine.lives, engine.width - 82, 22);

    if (engine.gameOver) {
      ctx.fillStyle = "rgba(0, 0, 0, 0.72)";
      ctx.fillRect(0, 0, engine.width, engine.height);
      ctx.fillStyle = "#ffffff";
      ctx.textAlign = "center";
      ctx.font = "bold 30px sans-serif";
      ctx.fillText("GAME OVER", engine.width / 2, engine.height / 2 - 12);
      ctx.font = "16px sans-serif";
      ctx.fillText("Pressione R para reiniciar", engine.width / 2, engine.height / 2 + 20);
      ctx.textAlign = "start";
    }
  }

  function attachPointerControl(button, activePointers) {
    if (!button) return;
    button.addEventListener("pointerdown", event => {
      event.preventDefault();
      activePointers.add(event.pointerId);
      button.setPointerCapture(event.pointerId);
    });
    for (const name of ["pointerup", "pointercancel", "lostpointercapture"]) {
      button.addEventListener(name, event => activePointers.delete(event.pointerId));
    }
  }

  function startBrowserGame() {
    if (typeof document === "undefined") return;
    const canvas = document.getElementById("gameCanvas");
    const ctx = canvas && canvas.getContext("2d");
    if (!canvas || !ctx) return;

    const engine = new GameEngine({ width: canvas.width, height: canvas.height });
    const keys = new Set();
    const pointers = { left: new Set(), right: new Set(), shoot: new Set() };
    for (const name of Object.keys(pointers)) {
      attachPointerControl(document.getElementById(`control-${name}`), pointers[name]);
    }
    const restart = document.getElementById("control-restart");
    if (restart) restart.addEventListener("click", () => engine.reset());
    window.addEventListener("keydown", event => {
      if (["ArrowLeft", "ArrowRight", " "].includes(event.key)) event.preventDefault();
      keys.add(event.key);
      if (event.key.toLowerCase() === "r" && engine.gameOver) engine.reset();
      if (event.key.toLowerCase() === "p") engine.togglePaused();
    });
    window.addEventListener("keyup", event => keys.delete(event.key));
    window.addEventListener("blur", () => {
      keys.clear();
      for (const active of Object.values(pointers)) active.clear();
    });

    let previous = 0;
    function frame(timestamp) {
      if (!previous) previous = timestamp;
      const delta = timestamp - previous;
      previous = timestamp;
      engine.update(delta, {
        left: keys.has("ArrowLeft") || keys.has("a") || keys.has("A") || pointers.left.size > 0,
        right: keys.has("ArrowRight") || keys.has("d") || keys.has("D") || pointers.right.size > 0,
        shoot: keys.has(" ") || pointers.shoot.size > 0
      });
      drawGame(ctx, engine);
      window.requestAnimationFrame(frame);
    }
    window.requestAnimationFrame(frame);
  }

  if (typeof module !== "undefined" && module.exports) {
    module.exports = { Player, GameEngine, intersects, attachPointerControl };
  }
  if (typeof window !== "undefined") startBrowserGame();
})(typeof globalThis !== "undefined" ? globalThis : this);
