# Verificação e evolução — Space Shooter JS

## Escopo confirmado

Jogo em HTML5 Canvas, com movimento, tiros, colisões e pontuação.

## Localização do código

`index.html`, `game.js`, `game.test.js`.

## Verificar localmente

Abrir `index.html` no navegador ou iniciar `python -m http.server 8000`; conferir como executar `game.test.js` no próprio arquivo de testes.

Use dados fictícios e registre no PR o comando, ambiente e resultado observado. Para projetos sem runtime instalado, marque a verificação como pendente em vez de afirmar que passou.

## Casos de regressão a cobrir

Testar disparos simultâneos, reinício após game over, teclas mantidas pressionadas, toque no celular e colisões em resoluções diferentes.

## Limitações e próximo incremento

Implementar testes determinísticos de sequência de frames e manter controles por toque acessíveis.

## Critérios de revisão

- [ ] O comportamento alterado está descrito com exemplo reproduzível.
- [ ] Há teste ou procedimento de validação compatível com o código real.
- [ ] Nenhuma chave, dado pessoal ou arquivo gerado foi incluído sem necessidade.
- [ ] A documentação distingue o implementado do planejado.
