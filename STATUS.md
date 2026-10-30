# STATUS DO PROJETO

## Etapa 1 - Fundacoes de Inteligencia Artificial
- [X] Pesquisar e definir a API de texto e criar script de verificacao de conectividade. A integracao funcional de efeitos e regras permanece na Etapa 7.
- [X] Pesquisar e definir os provedores de imagem e criar script de verificacao de resposta. A integracao com o aplicativo ainda esta planejada.
- [X] Validar a comunicacao com os provedores de IA, pois sao dependencias para os demais fluxos.
- [X] Criar o arquivo .gitignore com regras permissivas, garantindo o versionamento da documentacao e configuracao.

## Etapa 2 - Infraestrutura e Banco de Dados
- [X] Avaliar e provisionar o banco de dados online.
- [X] Configurar o Docker (Dockerfile e compose.yaml) para o ambiente local.
- [X] Criar o arquivo .env.example contendo as variaveis de ambiente necessarias.

## Etapa 3 - Autenticacao e UI Base (Flutter)
- [X] Inicializar o projeto Flutter na pasta /frontend.
- [X] Definir e aplicar o padrao global de UI/UX (Fundo preto, tracos dourados e rosa) no ThemeData do Flutter.
- [X] Implementar a pagina de criacao de usuario e Login no Flutter.
- [X] Implementar o bloqueio de rotas para usuarios nao autenticados.
- [X] Desenvolver a pagina inicial (Dashboard) com os cards de navegacao.
- [X] Implementar a aba de configuracoes (acessada por um icone de engrenagem no canto) para gerenciar dados da conta e preferencias.

## Etapa 4 - Backend: Modelagem de Usuário e Autenticação
- [X] Criar o modelo de dados de Usuário (Mongoose) contendo: nome, sobrenome, nome de usuário, email, idade, data de nascimento, sexo, origem no jogo (TCG, OCG, Master Duel, Duel Links), senha criptografada, ID da conta e plano da conta.
- [X] Implementar a lógica de geração automática e única do ID da conta para novos registros.
- [X] Desenvolver a rota de criação de conta (Registro) com validação dos campos obrigatórios e hash de senha (ex: bcrypt).
- [X] Desenvolver a rota de Login com geração de token de acesso (JWT) para proteger rotas futuras.
- [X] Sincronizar o formulário de registro do Flutter (Frontend) com a nova rota de criação de conta do backend.

## Etapa 5 - Modulo de Criacao de Cartas Individuais
- [ ] Desenvolver a interface de selecao do tipo inicial de carta (Monstro, Magia, Armadilha).
- [ ] Desenvolver os formularios de atributos, textos e estatisticas.
- [ ] Implementar a logica de salvar a carta no banco de dados online.
- [ ] Configurar o redirecionamento automatico para a pagina de visualizacao apos salvar.

## Etapa 6 - Gerenciamento e Deckbuilder
- [ ] Implementar a galeria geral de cartas, exibindo cartas individuais e de arquétipos.
- [ ] Implementar a funcionalidade de criar e gerenciar baralhos.
- [ ] Integrar a base de dados de cartas originais do jogo para uso misto com as cartas criadas.

## Etapa 7 - Modulo de Arquétipos assistido por IA
- [ ] Desenvolver a interface de chat com a IA para construcao de arquétipos.
- [ ] Implementar as restricoes de regras no prompt da IA (ex: delimitacao de custo ate o ponto e virgula).
- [ ] Adicionar fluxo de aprovacao ou rejeicao de efeitos gerados.
- [ ] Desenvolver o construtor de linhas de combo auxiliado pela IA.
- [ ] Implementar validador de coerencia do arquétipo.
- [ ] Configurar as mensagens de erro de coerencia (apontar as 1 ou mais cartas conflitantes, ou apontar erro geral no arquétipo caso a incompatibilidade ultrapasse 60%).

## Etapa 8 - Simulador de Duelos
- [ ] Estruturar o tabuleiro / field virtual.
- [ ] Implementar engine manual de manipulacao de cartas (Duelingbook style).

## Etapa 9 - Configuracoes (antecipada na Etapa 4)
- [X] Desenvolver interface e integracao para alterar dados da conta.
- [X] Implementar funcionalidade para desativar a conta temporariamente.
- [X] Implementar funcionalidade para apagar o cadastro definitivamente.
- [X] Adicionar opcao para alterar a forma de tratamento do usuario.
- [X] Estruturar a aba de configuracoes para permitir a adicao de novas opcoes ao longo do projeto.
- A exclusao dos futuros recursos vinculados (cartas, decks e artes) sera implementada junto de seus modulos. A interface atual promete apenas a exclusao do cadastro existente.

## Etapa de Testes (Multiplataforma, Banco de Dados e APIs)
> Testes a serem realizados: Verificacao de build e funcionamento em APK, EXE e Web; Validacao da integridade dos dados no MongoDB; Validacao de estabilidade das chamadas para as APIs de IA (Gemini e Hugging Face).
- [X] Testes automatizados da Etapa 4: regressao do backend e integracao HTTP com persistencia no MongoDB.
- [ ] Testes da Etapa 5 (Modulo de Criacao de Cartas Individuais)
- [ ] Testes da Etapa 6 (Gerenciamento e Deckbuilder)
- [ ] Testes da Etapa 7 (Modulo de Arquétipos assistido por IA)
- [ ] Testes da Etapa 8 (Simulador de Duelos)
- [X] Testes automatizados das configuracoes antecipadas: perfil, duplicidade, tratamento, desativacao, reativacao, revogacao e exclusao.

### Validacoes historicas anteriores a esta revisao
Os itens abaixo registram o estado anterior. Os resultados da revisao atual estao separados abaixo; build aprovado nao equivale a teste manual completo no dispositivo.

- [X] Backend em Docker conectado ao MongoDB Atlas, com health check e fluxo completo de registro, login, perfil, desativacao, reativacao e exclusao validados.
- [X] `flutter analyze` sem pendencias e 3 testes de widget aprovados.
- [X] Build Web (`flutter build web --release`) aprovado.
- [X] Build Windows (`flutter build windows --release`) aprovado.
- [X] Build Android (`flutter build apk --debug`) aprovado, com APK gerado em `frontend/build/app/outputs/flutter-apk/app-debug.apk`.
- [X] Validacao das APIs de IA: Gemini operante (com modelo alternativo) e Pollinations gerando imagens. Hugging Face permanece opcional.

## Alterações de Bugs Ocasionais
- Sessao do usuario era perdida ao reiniciar o aplicativo. Corrigido inicialmente com `shared_preferences`; nesta revisao token e perfil migraram para armazenamento protegido com `flutter_secure_storage`.
- Aplicativo Android sem permissao de internet, usando `localhost` e bloqueando HTTP em texto puro. Corrigido com permissao, `10.0.2.2` no emulador e configuracao de seguranca de rede para o backend local.
- Alteracao de e-mail era ignorada pelo backend e a tela exibia sucesso mesmo em caso de falha. Corrigido com atualizacao real, verificacao de duplicidade e retorno de erro para o usuario.
- Conta desativada nao podia ser reativada, apesar da mensagem exibida. Corrigido com reativacao automatica apos login valido.
- Backend aceitava data de nascimento invalida e usuarios com menos de 6 anos. Corrigido com validacao no registro e na atualizacao de perfil.
- Campos suspensos (`DropdownButtonFormField`) estouravam a largura em telas estreitas. Corrigido com `isExpanded`.
- Testes de widget travavam por causa da animacao continua da tela de login. Corrigido o uso de `pumpAndSettle`.

## Alterações de Design
- Titulo da janela Windows e nome do aplicativo Android alterados de "frontend" para "Make Your Card".
- Campos suspensos ajustados para ocupar a largura disponivel sem overflow em telas pequenas.

## Alterações de Arquitetura
- Removido Apache do escopo de consideracoes (nao havera uso de .htaccess).
- Adotado Flutter para o desenvolvimento do Frontend (visando exportacao para APK e EXE).
- Definida arquitetura Client-Server: Flutter (Client) se comunicara com o Node.js em Docker (Backend) para garantir a seguranca das chaves de API das IAs.
- Segredo JWT agora e obrigatorio no `.env` (minimo de 16 caracteres), sem valor padrao embutido no codigo.
- Adicionado limitador de requisicoes em memoria para autenticacao e para as rotas da API.
- CORS restrito a localhost e as origens declaradas em `CORS_ORIGINS`.
- URL da API no Flutter definida por plataforma, com possibilidade de sobrescrita via `--dart-define=API_BASE_URL`.
- Adicionado `.dockerignore` para reduzir o contexto de build.

## Estudos de APIs
- **IA de Texto:** Adotada a API do Google Gemini. Modelo padrao `gemini-3.8-flash`, com `gemini-3.6-flash` como alternativa automatica.
- **IA de Imagem:** Pollinations adotada como provedor padrao gratuito. Hugging Face permanece suportada de forma opcional quando configurada.
- **Banco de Dados:** Selecionado MongoDB Atlas (Tier M0 - Gratuito) para armazenamento das cartas, arquétipos e usuários.

## Revisao de fechamento da Etapa 4 - 28/10/2026
- [X] Contadores independentes por limitador, com teste de 15 autenticacoes permitidas e bloqueio da 16a.
- [X] Proxy confiavel desabilitado no acesso direto do Compose.
- [X] Validacao estrita de datas civis, idade minima, tipos, campos vazios, limites de tamanho e forma de tratamento.
- [X] JSON invalido retorna 400; corpo acima de 1 MB retorna 413; respostas nao expoem mensagens internas.
- [X] Colisao de e-mail na atualizacao retorna 409, inclusive em disputa de indice unico.
- [X] Desativacao incrementa a versao da sessao e impede reutilizacao dos tokens antigos apos reativacao.
- [X] Erros de banco sao separados de erros de autenticacao.
- [X] Sessao e perfil em armazenamento protegido, com migracao das preferencias antigas e fila de gravacoes.
- [X] Resposta antiga de validacao nao sobrescreve uma nova sessao; 401 encerra a sessao, enquanto falhas 500 preservam a sessao.
- [X] Expiracao remove as rotas privadas; dashboard observa mudancas do perfil.
- [X] Lockfile do backend liberado no Git; AGENT.md permanece local e ignorado por decisao do criador.
- [X] Docker usa npm ci na construcao, usuario sem privilegios e nao reinstala dependencias ao iniciar.
- [X] Metadados Web e Windows atualizados para Make Your Card.
- [X] Formularios adaptativos e identificacao da conta ajustados para telas estreitas e fontes ampliadas; envios duplicados de perfil bloqueados.
- [X] Verificacao de IA com tempo limite, rejeicao de texto vazio, fallback e aviso explicito sobre seu alcance.

### Resultados atuais da revisao
- [X] Backend: 13 testes automatizados aprovados em Docker, incluindo limites, datas, validacao, erros HTTP, revogacao, duplicidade e respostas da IA simuladas.
- [X] Integracao real com MongoDB Atlas aprovada, com criacao e limpeza de contas temporarias.
- [X] Flutter: 10 testes aprovados, cobrindo migracao, expiracao, preservacao da sessao em erro de servidor, resposta antiga, atualizacao de perfil, largura de 320 px com fonte ampliada e bloqueio de envios duplicados.
- [X] flutter analyze sem erros ou avisos.
- [X] Build Windows release aprovado.
- [X] Build Web release aprovado.
- [X] Build Android debug aprovado; APK normal regenerado apos o teste nativo e reinstalado no emulador.
- [X] Verificacao real de IA aprovada com fallback Gemini e imagem Pollinations; Hugging Face opcional nao configurada.
- [X] Teste nativo Windows de gravacao, leitura e exclusao no armazenamento protegido aprovado.
- [X] Teste nativo Android de gravacao, leitura e exclusao no armazenamento protegido aprovado no emulador Medium_Phone_API_37.0 apos reconexao pelo criador.
- Build aprovado e testes automatizados nao substituem uma revisao manual completa de todas as telas no aparelho fisico.

### Alcance da verificacao de IA
npm run test:ai testa apenas conectividade e formato basico da resposta. Nao ha rotas de IA consumidas pelo aplicativo e nao sao avaliados PSCT, balanceamento ou coerencia. O teste real desta revisao passou pelo modelo alternativo do Gemini e recebeu imagem de Pollinations. Hugging Face nao configurada foi ignorada como opcional. O sucesso do fallback nao comprova disponibilidade do modelo principal.

### Pendencias planejadas para as proximas etapas
- Etapa 5: definir tipos e variacoes de cartas, visibilidade, entrada de arte, formato da visualizacao/exportacao e politica de bloqueio ou aviso para combinacoes fora das regras.
- Etapas 5 e 6: vincular dados ao proprietario e implementar exclusao consistente de cartas, decks e arquivos junto com a conta.
- Etapa 7: implementar servicos e rotas de IA, chat, PSCT, aprovacao de efeitos e validadores de coerencia.
- Publicacao Android: definir identificador definitivo do pacote e assinatura de release. O APK atual e de debug.
- Hospedagem: definir URL HTTPS e infraestrutura de producao; configuracoes atuais sao locais. A Web permanece destino complementar ate definicao de suporte oficial.
- Fechamento: revisao do criador e um unico commit/push referente a Etapa 4. Nenhum commit ou push foi executado nesta revisao.

### Pendencias urgentes desta revisao
Nenhuma dependencia externa pendente. A compilacao Android e os testes nativos de armazenamento em Windows e Android foram aprovados. Permanecem as decisoes de produto e publicacao das proximas etapas, listadas acima.
