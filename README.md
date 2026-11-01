# Space Shooter JS

Protótipo de jogo em navegador usando HTML5 Canvas e JavaScript puro.

## Estado atual

O jogo inclui movimento lateral, disparos com intervalo, inimigos, colisões, pontuação, três vidas e reinício após game over. A dificuldade aumenta gradualmente conforme a pontuação.

## Executar

Abra `index.html` em um navegador moderno. Para desenvolvimento, também é possível usar um servidor HTTP local:

```bash
python -m http.server 8000
```

Acesse `http://localhost:8000`.

## Arquivos

- `index.html`: estrutura da página e canvas.
- `game.js`: lógica do jogo, controles, atualização e renderização.
- `game.test.js`: testes automatizados da lógica usando o test runner nativo do Node.js.

## Tecnologias

- HTML5 Canvas
- JavaScript
- APIs do navegador

## Próximas melhorias

- Adicionar controles de movimento e disparo.
- Implementar inimigos, colisões, vidas e condição de fim de jogo.
- Separar atualização do estado e renderização.
- Adicionar testes para a lógica independente do canvas.

## Testes

Com Node.js 20 ou superior, execute:

```bash
node --test game.test.js
```

Projeto experimental em evolução.
