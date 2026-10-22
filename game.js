const canvas = document.getElementById('gameCanvas');
const ctx = canvas ? canvas.getContext('2d') : null;

class Player {
    constructor() {
        this.x = 280;
        this.y = 350;
        this.width = 40;
        this.height = 30;
        this.score = 0;
    }

    draw(context) {
        if (!context) return;
        context.fillStyle = '#3b82f6';
        context.fillRect(this.x, this.y, this.width, this.height);
    }
}

const player = new Player();

function gameLoop() {
    if (ctx) {
        ctx.clearRect(0, 0, 600, 400);
        player.draw(ctx);
        ctx.fillStyle = '#ffffff';
        ctx.fillText(`Score: ${player.score}`, 10, 20);
    }
}

if (typeof window !== 'undefined') {
    setInterval(gameLoop, 1000 / 60);
}

if (typeof module !== 'undefined') {
    module.exports = { Player };
}
