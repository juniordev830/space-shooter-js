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

> **Acesso pela internet:** o comando acima disponibiliza o jogo apenas na sua máquina/rede local; ele não publica o projeto na internet. Para acesso público, é necessário hospedá-lo em um serviço de páginas estáticas, como GitHub Pages, e configurar a publicação.

## Arquivos

- `index.html`: estrutura da página e canvas.
- `game.js`: lógica do jogo, controles, atualização e renderização.
- `game.test.js`: testes automatizados da lógica usando o test runner nativo do Node.js.

## Tecnologias

- HTML5 Canvas
- JavaScript
- APIs do navegador

## Próximas melhorias

- Separar atualização do estado e renderização.
- Ampliar os testes da lógica independente do canvas.
- Melhorar acessibilidade e controles em telas sensíveis ao toque.

## Testes

Com Node.js 20 ou superior, execute:

```bash
node --test game.test.js
```

Projeto experimental em evolução.
