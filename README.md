## Script de Automação de Build
Este script automatiza o processo de build para projetos AEM, incluindo a configuração inicial, limpeza de diretórios, inicialização do AEM, login automático e execução de builds específicos. Ele suporta múltiplos projetos e verifica a necessidade de compilar dependências comuns antes de proceder com o build principal.

## Funcionalidades:
- Deleta o diretório CRX se existente e reinicia o AEM.
- Executa login automático no AEM.
- Permite escolher entre diferentes projetos e tipos de build.
- Realiza build de dependências comuns, se necessário.
- Aplica versões extraídas do pom.xml quando aplicável.
## Uso:
Execute o script e siga as instruções no terminal para escolher o projeto e o tipo de build desejado.