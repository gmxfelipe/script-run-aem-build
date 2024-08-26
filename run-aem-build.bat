@echo off
setlocal EnableDelayedExpansion

rem Caminhos para o AEM jar e CRX
set AEM_JAR_PATH=C:/Users/felipe.o/projeto-cloud-service/servers/author/aem-sdk/aem-author-p4502.jar
set CRX_DIR=C:/Users/felipe.o/projeto-cloud-service/servers/author/aem-sdk/crx-quickstart

rem Caminho para as pastas dos projetos
set PROJECT1_PATH=C:/Users/felipe.o/projeto-cloud-service/azure/projects/aem-equipamentos-loja-online
set PROJECT2_PATH=C:/Users/felipe.o/projeto-cloud-service/azure/projects/aem-equipamentos-vivo-tech
set PROJECT3_PATH=C:/Users/felipe.o/projeto-cloud-service/azure/projects/vivo-portal-aem
set PROJECT4_PATH=C:/Users/felipe.o/projeto-cloud-service/azure/projects/aem-telco
set COMMON_PATH=C:/Users/felipe.o/projeto-cloud-service/azure/projects/aem-common

rem Nome dos projetos
set PROJECT1_NAME=aem-equipamentos-loja-online
set PROJECT2_NAME=aem-equipamentos-vivo-tech
set PROJECT3_NAME=vivo-portal-aem
set PROJECT4_NAME=aem-telco

rem Credenciais para login no AEM
set AEM_USER=admin
set AEM_PASS=admin

if not exist "%CRX_DIR%" (
    echo Diretorio CRX nao existe. Pulando para o passo de iniciar o AEM...
    goto StartAEM
)

echo Tentando deletar o diretorio CRX...
rmdir /S /Q "%CRX_DIR%"
if errorlevel 1 (
    echo Falha ao apagar o diretorio CRX. Saindo do script...
    goto end
) else (
    echo Diretorio CRX apagado com sucesso.
)

:StartAEM
echo Iniciando AEM...
start "" "%AEM_JAR_PATH%"

:waitForAEM
echo Aguardando o AEM iniciar...
timeout /t 10 >nul
curl --head --silent http://localhost:4502/libs/granite/core/content/login.html | find "200 OK" >nul
if errorlevel 1 (
    echo AEM ainda nao esta disponivel, aguardando...
    goto waitForAEM
)

echo AEM esta rodando, realizando login...

curl -u %AEM_USER%:%AEM_PASS% http://localhost:4502/libs/granite/core/content/login.html >nul

echo Login realizado com sucesso!

echo Escolha o projeto para buildar:
echo 1. %PROJECT1_NAME%
echo 2. %PROJECT2_NAME%
echo 3. %PROJECT3_NAME%
echo 4. %PROJECT4_NAME%
set /p choice="Digite o numero do projeto: "

if "%choice%"=="1" (
    set PROJECT_PATH=%PROJECT1_PATH%
    set PROJECT_NAME=%PROJECT1_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="2" (
    set PROJECT_PATH=%PROJECT2_PATH%
    set PROJECT_NAME=%PROJECT2_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="3" (
    set PROJECT_PATH=%PROJECT3_PATH%
    set PROJECT_NAME=%PROJECT3_NAME%
    set NEED_COMMON_BUILD=0
) else if "%choice%"=="4" (
    set PROJECT_PATH=%PROJECT4_PATH%
    set PROJECT_NAME=%PROJECT4_NAME%
    set NEED_COMMON_BUILD=1
) else (
    echo Opcao invalida. Saindo...
    goto end
)

echo Voce escolheu %PROJECT_NAME%.

if "%NEED_COMMON_BUILD%"=="1" (
    echo Esse projeto requer o build do common.
    set /p COMMON_BRANCH="Digite o nome da branch do common para buildar: "
    cd /d "%COMMON_PATH%"
    git checkout %COMMON_BRANCH%
    git pull origin %COMMON_BRANCH%
    start cmd /k "mvn clean install -Padobe-public,autoInstallPackage,autoInstallBundle -Daem.port=4502 && pause"

    echo Extraindo a versao do pom.xml...
    set "VERSION="

    for /f "tokens=1,* delims=<>" %%a in ('findstr /i "<version>" "%COMMON_PATH%\pom.xml"') do (
        if not defined VERSION (
            set "temp=%%b"
            set "temp=!temp: =!"
            set "VERSION=!temp:version>=!"
            set "VERSION=!VERSION:</version>=!"
            for /f "delims=<> tokens=1" %%c in ("!VERSION!") do set "VERSION=%%c"
        )
    )
)

set /p BRANCH_NAME="Digite o nome da branch do projeto principal que deseja buildar: "

cd /d "%PROJECT_PATH%"
git checkout %BRANCH_NAME%
git pull origin %BRANCH_NAME%

if "%NEED_COMMON_BUILD%"=="1" if defined VERSION (
    echo Aplicando a versao encontrada: %VERSION%
    start cmd /k "cd /d %PROJECT_PATH% && mvn versions:set -DnewVersion=%VERSION% && pause"
) else (
    echo Nenhuma versao encontrada no pom.xml. Pulando ajuste de versao.
)

echo Escolha o tipo de build:
echo 1. mvn clean install -Padobe-public,autoInstallPackage,autoInstallBundle
echo 2. mvn clean install -PautoInstallSinglePackage
set /p BUILD_CHOICE="Digite o numero da build: "

if "%BUILD_CHOICE%"=="1" (
    set BUILD_COMMAND=mvn clean install -Padobe-public,autoInstallPackage,autoInstallBundle -Daem.port=4502
) else if "%BUILD_CHOICE%"=="2" (
    set BUILD_COMMAND=mvn clean install -PautoInstallSinglePackage -Daem.port=4502
) else (
    echo Opcao invalida. Saindo...
    goto end
)

start cmd /k "%BUILD_COMMAND% && pause"

:end
echo Processo concluido. Pressione qualquer tecla para sair...
pause >nul
