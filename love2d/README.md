# Space Shooter em Lua / LÖVE2D

Versão **alternativa jogável** do Space Shooter construída em Lua 5.4 e LÖVE2D. A versão web existente em JavaScript permanece intacta.

## Executar o jogo

Instale o framework [LÖVE2D](https://love2d.org/) 11.x e, na raiz do repositório, execute:

```bash
love love2d
```

Controles: setas ou A/D para mover, Espaço para atirar, **S para ativar escudo**, P para pausar, R para reiniciar após o fim de jogo.

## Novas mecânicas

- **Combos de pontuação:** destrua inimigos em sequência (até 3 segundos entre acertos) para ganhar de 1x a 5x pontos. Perder uma vida ou deixar o tempo acabar encerra o combo.
- **Cápsulas de reparo:** a cada 5 inimigos eliminados surge uma cápsula verde. Pegue-a com a nave para recuperar uma vida (máximo de 3). Cápsulas perdidas não custam vidas.
- **Fases progressivas:** a cada 100 pontos o nível aumenta, acelerando surgimento e velocidade dos inimigos.
- **Escudo temporário:** a tecla S ativa proteção contra contato direto com inimigos por 2 segundos. A partida começa com uma carga e concede outra por nível, até 3.
- **Recorde local:** o melhor resultado fica salvo automaticamente por LÖVE no arquivo `recorde.txt` da pasta de dados do aplicativo, fora do repositório.
- Inimigos que saem da tela continuam reduzindo vidas mesmo com escudo ativo.

## Testar sem interface gráfica

Instale Lua 5.4 e execute na raiz do repositório:

```bash
lua5.4 love2d/test_engine.lua
```

Os testes verificam movimento e limites, intervalo entre tiros, colisões, perda de vidas, reinício, pausa, progressão, proteção temporária, cápsulas de reparo e recorde em memória, sem precisar instalar LÖVE2D.

## Estrutura

- `main.lua`: interface, controles e renderização LÖVE2D.
- `engine.lua`: regras de jogo separadas da interface.
- `test_engine.lua`: testes das regras de jogo em Lua puro.

A mecânica replica os conceitos principais da edição JavaScript. São implementações separadas, não compartilham código entre runtimes.
