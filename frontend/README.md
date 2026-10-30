# Make Your Card

Aplicativo Flutter para criacao e gerenciamento de cartas customizadas de Yu-Gi-Oh!.

As plataformas principais sao Windows e Android. A Web e validada como destino complementar. O backend deve estar em execucao via Docker.

Consulte o README.md e o STATUS.md na raiz para configuracao, comandos, testes e limitacoes.

A URL da API pode ser definida com --dart-define=API_BASE_URL=https://seu-servidor/api. No emulador Android, o padrao e http://10.0.2.2:3000/api; Windows e Web usam http://localhost:3000/api. Dispositivos fisicos precisam da URL do servidor e, durante desenvolvimento HTTP, da permissao do dominio na configuracao Android.
