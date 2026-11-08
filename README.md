# Space Shooter — JavaScript + Lua

Protótipo de jogo em navegador usando HTML5 Canvas e JavaScript puro, com uma **segunda versão jogável em Lua/LÖVE2D**.

## Estado atual

O jogo inclui movimento lateral, disparos com intervalo, inimigos, colisões, pontuação, três vidas e reinício após game over. A dificuldade aumenta gradualmente conforme a pontuação.

Em celulares e tablets, mantenha pressionados os botões de movimento e de disparo na tela. O botão Reiniciar começa uma nova partida. No computador, os controles por teclado continuam disponíveis.

## Executar

Abra `index.html` em um navegador moderno. Para desenvolvimento, também é possível usar um servidor HTTP local:

```bash
python -m http.server 8000
```

Acesse `http://localhost:8000`.

> **Acesso pela internet:** o comando acima disponibiliza o jogo apenas na sua máquina/rede local; ele não publica o projeto na internet. Para acesso público, é necessário hospedá-lo em um serviço de páginas estáticas, como GitHub Pages, e configurar a publicação.

## Versão alternativa em Lua

Uma versão desktop feita com **Lua e LÖVE2D** está disponível em [`love2d/`](love2d/README.md). Mantém movimentação, tiros, pontuação e vidas, com lógica independente da interface e testes automatizados em Lua:

```bash
love love2d
lua5.4 love2d/test_engine.lua
```

A primeira linha exige LÖVE2D 11.x. A segunda exige Lua 5.4 e pode ser executada sem ambiente gráfico. O jogo do navegador não depende de Lua.

## Arquivos

- `index.html`: estrutura da página e canvas.
- `game.js`: lógica do jogo, controles, atualização e renderização.
- `game.test.js`: testes automatizados da lógica usando o test runner nativo do Node.js.

## Tecnologias

- HTML5 Canvas
- JavaScript
- APIs do navegador
- Lua 5.4 e LÖVE2D (variante desktop)

## Próximas melhorias

- Separar atualização do estado e renderização.
- Ampliar os testes da lógica independente do canvas.
- Melhorar a acessibilidade e adicionar feedback sonoro opcional.

## Testes

Com Node.js 20 ou superior, execute:

```bash
node --test game.test.js
```

Projeto experimental em evolução.
