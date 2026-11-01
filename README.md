# Space Shooter JS

Protótipo de jogo em navegador usando HTML5 Canvas e JavaScript puro.

## Estado atual

A implementação atual desenha a nave do jogador e uma pontuação inicial em um canvas. Ainda é uma base inicial de jogo: mecânicas completas de tiro, inimigos, colisões e progressão precisam ser implementadas antes de serem anunciadas como recursos disponíveis.

## Executar

Abra `index.html` em um navegador moderno. Para desenvolvimento, também é possível usar um servidor HTTP local:

```bash
python -m http.server 8000
```

Acesse `http://localhost:8000`.

## Arquivos

- `index.html`: estrutura da página e canvas.
- `game.js`: estado e renderização básica do jogador.

## Tecnologias

- HTML5 Canvas
- JavaScript
- APIs do navegador

## Próximas melhorias

- Adicionar controles de movimento e disparo.
- Implementar inimigos, colisões, vidas e condição de fim de jogo.
- Separar atualização do estado e renderização.
- Adicionar testes para a lógica independente do canvas.

Projeto experimental em desenvolvimento.
