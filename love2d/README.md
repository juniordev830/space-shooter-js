# Space Shooter em Lua / LÖVE2D

Versão **alternativa jogável** do Space Shooter construída em Lua 5.4 e LÖVE2D. A versão web existente em JavaScript permanece intacta.

## Executar o jogo

Instale o framework [LÖVE2D](https://love2d.org/) 11.x e, na raiz do repositório, execute:

```bash
love love2d
```

Controles: setas ou A/D para mover, Espaço para atirar, P para pausar, R para reiniciar após o fim de jogo.

## Testar sem interface gráfica

Instale Lua 5.4 e execute na raiz do repositório:

```bash
lua5.4 love2d/test_engine.lua
```

Os testes verificam movimento e limites, intervalo entre tiros, colisões, perda de vidas, reinício e pausa, sem precisar instalar LÖVE2D.

## Estrutura

- `main.lua`: interface, controles e renderização LÖVE2D.
- `engine.lua`: regras de jogo separadas da interface.
- `test_engine.lua`: testes das regras de jogo em Lua puro.

A mecânica replica os conceitos principais da edição JavaScript. São implementações separadas, não compartilham código entre runtimes.
