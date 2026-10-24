# STATUS DO PROJETO

## Etapa 1 - Fundacoes de Inteligencia Artificial
- [X] Pesquisar, definir e integrar a API de IA para geracao de textos, efeitos e analise de regras.
- [X] Pesquisar, definir e integrar a API de IA para geracao de artes das cartas.
- [X] Validar a comunicacao com os provedores de IA, pois sao dependencias para os demais fluxos.
- [X] Criar o arquivo .gitignore com regras permissivas, garantindo o versionamento da documentacao e configuracao.

## Etapa 2 - Infraestrutura e Banco de Dados
- [X] Avaliar e provisionar o banco de dados online.
- [X] Configurar o Docker (Dockerfile e compose.yaml) para o ambiente local.
- [X] Criar o arquivo .env.example contendo as variaveis de ambiente necessarias.

## Etapa 3 - Autenticacao e UI Base (Flutter)
- [ ] Inicializar o projeto Flutter na pasta /frontend.
- [ ] Definir e aplicar o padrao global de UI/UX (Fundo preto, tracos dourados e rosa) no ThemeData do Flutter.
- [ ] Implementar a pagina de criacao de usuario e Login no Flutter.
- [ ] Implementar o bloqueio de rotas para usuarios nao autenticados.
- [ ] Desenvolver a pagina inicial (Dashboard) com os cards de navegacao.

## Etapa 4 - Modulo de Criacao de Cartas Individuais
- [ ] Desenvolver a interface de selecao do tipo inicial de carta (Monstro, Magia, Armadilha).
- [ ] Desenvolver os formularios de atributos, textos e estatisticas.
- [ ] Implementar a logica de salvar a carta no banco de dados online.
- [ ] Configurar o redirecionamento automatico para a pagina de visualizacao apos salvar.

## Etapa 5 - Gerenciamento e Deckbuilder
- [ ] Implementar a galeria geral de cartas, exibindo cartas individuais e de arquétipos.
- [ ] Implementar a funcionalidade de criar e gerenciar baralhos.
- [ ] Integrar a base de dados de cartas originais do jogo para uso misto com as cartas criadas.

## Etapa 6 - Modulo de Arquétipos assistido por IA
- [ ] Desenvolver a interface de chat com a IA para construcao de arquétipos.
- [ ] Implementar as restricoes de regras no prompt da IA (ex: delimitacao de custo ate o ponto e virgula).
- [ ] Adicionar fluxo de aprovacao ou rejeicao de efeitos gerados.
- [ ] Desenvolver o construtor de linhas de combo auxiliado pela IA.
- [ ] Implementar validador de coerencia do arquétipo.
- [ ] Configurar as mensagens de erro de coerencia (apontar as 1 ou mais cartas conflitantes, ou apontar erro geral no arquétipo caso a incompatibilidade ultrapasse 60%).

## Etapa 7 - Simulador de Duelos
- [ ] Estruturar o tabuleiro / field virtual.
- [ ] Implementar engine manual de manipulacao de cartas (Duelingbook style).

## Alterações de Bugs Ocasionais
- [Nenhum bug registrado no momento]

## Alterações de Design
- [Nenhuma alteração registrada no momento]

## Alterações de Arquitetura
- Removido Apache do escopo de consideracoes (nao havera uso de .htaccess).
- Adotado Flutter para o desenvolvimento do Frontend (visando exportacao para APK e EXE).
- Definida arquitetura Client-Server: Flutter (Client) se comunicara com o Node.js em Docker (Backend) para garantir a seguranca das chaves de API das IAs.

## Estudos de APIs
- **IA de Texto:** Adotada a API do Google Gemini (Free Tier) devido a capacidade de contexto e gratuidade.
- **IA de Imagem:** Adotada a Hugging Face Inference API / Pollinations para geração gratuita de imagens.
- **Banco de Dados:** Selecionado MongoDB Atlas (Tier M0 - Gratuito) para armazenamento das cartas, arquétipos e usuários.