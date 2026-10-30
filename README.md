# Make Your Card (Yu-Gi-Oh!)

## Sobre o Projeto
Software multiplataforma (Desktop Windows e Android) para criacao, edicao, organizacao e gerenciamento de arquétipos e cartas customizadas do card game Yu-Gi-Oh!. Desenvolvido em Flutter para o frontend e Node.js para o backend, o aplicativo oferece ferramentas auxiliadas por Inteligencia Artificial para facilitar o balanceamento e a criacao de mecanicas. Seu objetivo é alimentar o hobby da comunidade e deixar mais fácil a criação de seus arquétipos próprios para jogar for fun.

## Funcionalidades Principais
- Criacao de Cartas Individuais: Suporte para desenhar Monstros, Magias e Armadilhas com regras oficiais.
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
## Estado da integracao de IA
As chamadas existentes em src/validator.js verificam conectividade e respostas dos provedores. O comando npm run test:ai faz chamadas reais: Gemini exige texto nao vazio, tenta novamente e pode usar o modelo alternativo; Pollinations exige resposta de imagem. Hugging Face e opcional, e uma falha nela e reportada como aviso.

Esta verificacao nao comprova regras PSCT, balanceamento, coerencia, estabilidade prolongada ou funcionamento de IA no aplicativo. Ainda nao existem rotas de IA consumidas pelo Flutter. Esses fluxos pertencem a Etapa 7. Os nomes de modelo sao configuraveis no ambiente; o sucesso com fallback nao comprova disponibilidade do modelo principal.

## Desenvolvimento e validacao
- Copie .env.example para .env e configure DB_URI e JWT_SECRET. Nunca versione .env.
- Execute docker compose up -d --build. Depois de alterar o backend ou dependencias, reconstrua a imagem com esse mesmo comando.
- A imagem instala as dependencias com npm ci a partir do package-lock.json versionado e roda com usuario sem privilegios. O Compose nao monta o codigo local nem reinstala pacotes ao iniciar.
- docker compose exec -T app npm test: testes automatizados de regressao, sem acesso ao Atlas ou provedores externos.
- docker compose exec -T app npm run test:integration: fluxo HTTP e persistencia no Atlas, usando apenas contas temporarias identificadas por esta execucao, removidas ao terminar.
- docker compose exec -T app npm run test:db: conectividade com MongoDB.
- docker compose exec -T app npm run test:ai: verificacao real dos provedores de IA, sujeita a disponibilidade e cota.
- Em frontend: flutter pub get, flutter analyze e flutter test; builds com flutter build windows --release, flutter build web --release e flutter build apk --debug.

## Sessao e ambiente
O token e o perfil sao armazenados por flutter_secure_storage, com migracao das preferencias antigas. A implementacao segue a [documentacao do pacote](https://pub.dev/packages/flutter_secure_storage). Na Web, o armazenamento exige HTTPS ou localhost. As plataformas principais continuam sendo Windows e Android; o build Web e uma validacao complementar.

A API retorna 401 para sessoes invalidas; o aplicativo encerra a sessao e remove o historico de telas privadas. Falhas de rede ou de servidor preservam a sessao para uma nova tentativa. A desativacao revoga todos os tokens anteriores. Tokens criados antes da introducao da versao de sessao exigem novo login.

O backend atual recebe conexoes diretamente e nao confia em cabecalhos de proxy. Antes de instalar um proxy reverso, configure explicitamente apenas os proxies confiaveis. Os limites em memoria atendem uma instancia; uma implantacao com varias replicas precisara de armazenamento compartilhado para os contadores.

A exclusao remove o cadastro de usuario. A politica de exclusao dos futuros arquivos, cartas e decks deve ser implementada junto desses modulos, antes de disponibiliza-los.

AGENT.md e um documento local de orientacao do criador e dos agentes de IA, intencionalmente fora do versionamento. O fechamento da Etapa 4 sera feito em um unico commit e push apos a revisao do criador.

Teste nativo do armazenamento protegido: em frontend, execute flutter test integration_test/storage_test.dart -d windows ou use o identificador de um emulador Android conectado. O teste utiliza uma chave temporaria isolada e a remove ao terminar.
