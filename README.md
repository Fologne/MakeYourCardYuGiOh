# Make Your Card (Yu-Gi-Oh!)

## Sobre o Projeto
Software multiplataforma (Desktop Windows e Android) para criacao, edicao, organizacao e gerenciamento de arquétipos e cartas customizadas do card game Yu-Gi-Oh!. Desenvolvido em Flutter para o frontend e Node.js para o backend, o aplicativo oferece ferramentas auxiliadas por Inteligencia Artificial para facilitar o balanceamento e a criacao de mecanicas. Seu objetivo é alimentar o hobby da comunidade e deixar mais fácil a criação de seus arquétipos próprios para jogar for fun.

## Funcionalidades Principais
- Criacao de Cartas Individuais: Suporte para desenhar Monstros, Magias e Armadilhas com regras oficias.
- Criacao de Arquétipos com IA: Chat integrado com Inteligencia Artificial para estruturar arquétipos, garantir a aplicacao de regras de resolucao (como separar custos por ponto e virgula), gerar linhas de combo e avaliar a coerencia e o balanceamento entre as cartas.
- Geracao de Imagens: Modulo integrado de IA para gerar as artes das cartas, com suporte para upload manual.
- Gerenciamento e Deckbuilder: Armazenamento online, visualizacao de cartas criadas e montagem de baralhos misturando cartas customizadas e cartas oficiais do jogo.
- Simulador Manual de Duelos: Ambiente de jogo nos moldes do Duelingbook, focado em interacao manual e explicacao dos efeitos entre os jogadores.

## Interface e UI/UX
A aplicacao adota um design moderno com esquema de cores escuro (fundo preto), acentuado por detalhes em dourado e, quando harmonico, toques de rosa, promovendo uma experiencia premium e focada no conteudo das cartas.

## Infraestrutura
O projeto adota uma arquitetura Client-Server dividida em:
- Frontend: Desenvolvido em Flutter, compilado para APK e EXE.
- Backend: Desenvolvido em Node.js e containerizado com Docker desde sua concepcao para garantir a reprodutibilidade.
Todas as chaves de API e credenciais de banco de dados sao isoladas no backend via variaveis de ambiente (.env), garantindo que nenhum segredo seja exposto nos binarios do aplicativo.