@echo off
setlocal EnableDelayedExpansion

rem Chama o script PowerShell para selecionar o arquivo JAR
echo Por favor, selecione o arquivo JAR necessario para iniciar o AEM
for /f "delims=" %%i in ('powershell -ExecutionPolicy Bypass -File SelectFolder.ps1 -type file') do set AEM_JAR_PATH=%%i
if not defined AEM_JAR_PATH (
    echo Nenhum arquivo JAR foi selecionado. Saindo do script
    goto end
)
echo Caminho do arquivo JAR selecionado: %AEM_JAR_PATH%

rem Chama o script PowerShell para selecionar a pasta CRX
echo Agora, selecione a pasta CRX que sera usada pelo AEM
for /f "delims=" %%i in ('powershell -ExecutionPolicy Bypass -File SelectFolder.ps1 -type folder') do set CRX_DIR=%%i
if not defined CRX_DIR (
    echo Nenhuma pasta CRX foi selecionada. Saindo do script
    goto end
)
echo Caminho da pasta CRX selecionada: %CRX_DIR%

set PROJECT1_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ADBB%%20-%%20ADOBE%%20EXPERIENCE%%20MANAGER%%20B2B/_git/aem-telco
set PROJECT2_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ADBB%%20-%%20ADOBE%%20EXPERIENCE%%20MANAGER%%20B2B/_git/aem-meu-vivo
set PROJECT3_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ADBB%%20-%%20ADOBE%%20EXPERIENCE%%20MANAGER%%20B2B/_git/aem-equipamentos-presencial
set PROJECT4_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ADBB%%20-%%20ADOBE%%20EXPERIENCE%%20MANAGER%%20B2B/_git/aem-equipamentos-loja-online
set PROJECT5_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ADBB%%20-%%20ADOBE%%20EXPERIENCE%%20MANAGER%%20B2B/_git/aem-equipamentos-vivo-tech
set PROJECT6_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ECMC%%20-%%20Ecomm%%20Cloud%%20B2C/_git/vivo-portal-aem
set COMMON_REPO_URL=https://telefonica-vivo-brasil@dev.azure.com/telefonica-vivo-brasil/ADBB%%20-%%20ADOBE%%20EXPERIENCE%%20MANAGER%%20B2B/_git/aem-common

set PROJECT1_NAME=aem-telco
set PROJECT2_NAME=aem-meu-vivo
set PROJECT3_NAME=aem-equipamentos-presencial
set PROJECT4_NAME=aem-equipamentos-loja-online
set PROJECT5_NAME=aem-equipamentos-vivo-tech
set PROJECT6_NAME=vivo-portal-aem

set AEM_USER=admin
set AEM_PASS=admin

set PROJECTS_DIR=%USERPROFILE%\projetos-vivo-script
set COMMON_DIR=%USERPROFILE%\projetos-vivo-script\aem-common

if exist "%PROJECTS_DIR%" (
    echo A pasta de projetos ja existe. Removendo.
    rmdir /S /Q "%PROJECTS_DIR%"
    if errorlevel 1 (
        echo Falha ao remover a pasta de projetos. Verifique as permissoes e tente novamente.
    ) else (
        echo Pasta de projetos removida com sucesso.
    )
)

echo Criando a pasta de projetos.
mkdir "%PROJECTS_DIR%"
if errorlevel 1 (
    echo Falha ao criar a pasta de projetos. Verifique as permissoes e tente novamente.
) else (
    echo Pasta de projetos criada com sucesso.
)

if not exist "%CRX_DIR%" (
    echo Diretorio CRX nao existe. Pulando para o passo de iniciar o AEM.
    goto StartAEM
)

echo Tentando deletar o diretorio CRX.
rmdir /S /Q "%CRX_DIR%"
if errorlevel 1 (
    echo Falha ao apagar o diretorio CRX. Saindo do script.
    goto end
) else (
    echo Diretorio CRX apagado com sucesso.
)


:StartAEM
echo Iniciando AEM.
start "" "%AEM_JAR_PATH%"

:waitForAEM
echo Aguardando o AEM iniciar.
timeout /t 60 >nul
curl --head --silent http://localhost:4502/libs/granite/core/content/login.html | find "200 OK" >nul
if errorlevel 1 (
    echo AEM ainda nao esta disponivel, aguardando.
    goto waitForAEM
)

echo AEM esta rodando, realizando login.
curl -u %AEM_USER%:%AEM_PASS% http://localhost:4502/libs/granite/core/content/login.html >nul
echo Login realizado com sucesso!

echo Escolha o projeto para clonar:
echo 1. %PROJECT1_NAME%
echo 2. %PROJECT2_NAME%
echo 3. %PROJECT3_NAME%
echo 4. %PROJECT4_NAME%
echo 5. %PROJECT5_NAME%
echo 6. %PROJECT6_NAME%
set /p choice="Digite o numero do projeto: "

if "%choice%"=="1" (
    set PROJECT_URL=%PROJECT1_URL%
    set PROJECT_NAME=%PROJECT1_NAME%
    set PROJECT_PATH=%PROJECTS_DIR%\%PROJECT1_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="2" (
    set PROJECT_URL=%PROJECT2_URL%
    set PROJECT_NAME=%PROJECT2_NAME%
    set PROJECT_PATH=%PROJECTS_DIR%\%PROJECT2_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="3" (
    set PROJECT_URL=%PROJECT3_URL%
    set PROJECT_NAME=%PROJECT3_NAME%
    set PROJECT_PATH=%PROJECTS_DIR%\%PROJECT3_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="4" (
    set PROJECT_URL=%PROJECT4_URL%
    set PROJECT_NAME=%PROJECT4_NAME%
    set PROJECT_PATH=%PROJECTS_DIR%\%PROJECT4_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="5" (
    set PROJECT_URL=%PROJECT5_URL%
    set PROJECT_NAME=%PROJECT5_NAME%
    set PROJECT_PATH=%PROJECTS_DIR%\%PROJECT5_NAME%
    set NEED_COMMON_BUILD=1
) else if "%choice%"=="6" (
    set PROJECT_URL=%PROJECT6_URL%
    set PROJECT_NAME=%PROJECT6_NAME%
    set PROJECT_PATH=%PROJECTS_DIR%\%PROJECT6_NAME%
    set NEED_COMMON_BUILD=0
) else (
    echo Opção invalida. Saindo.
    goto end
)

echo Voce escolheu %PROJECT_NAME%.

echo aqui deveria sair o caminho "%PROJECTS_DIR%"
cd /d "%PROJECTS_DIR%"
echo Clonando o repositorio %PROJECT_NAME%.
git clone "%PROJECT_URL%" "%PROJECT_PATH%"
if errorlevel 1 (
    echo Falha ao clonar o repositorio. Saindo.
    goto end
)

cd /d "%COMMON_DIR%"
if "%NEED_COMMON_BUILD%"=="1" (
    echo Esse projeto requer o build do common.

    cd /d "%PROJECTS_DIR%"
    if errorlevel 1 (
        echo Falha ao acessar o diretorio base. Saindo.
        goto end
    )
    
    echo Clonando o repositrio common.
    git clone "%COMMON_REPO_URL%"
    if errorlevel 1 (
        echo Falha ao clonar o repositorio common. Saindo.
        goto end
    )

    rem Verificar se o diretório do common foi criado
    echo aqui deveria sair o caminho "%COMMON_DIR%"
    if not exist "%COMMON_DIR%" (
        echo O diretorio do common nao foi criado. Saindo.
        goto end
    )

    rem Navegar para o diretório do common
    cd /d "%COMMON_DIR%"
    if errorlevel 1 (
        echo Falha ao acessar o diretorio do common. Saindo.
        goto end
    )

    set /p COMMON_BRANCH="Digite o nome da branch do common para buildar: "
    git checkout %COMMON_BRANCH%
    if errorlevel 1 (
        echo Falha ao trocar para a branch %COMMON_BRANCH%. Saindo.
        goto end
    )
    git pull origin %COMMON_BRANCH%
    if errorlevel 1 (
        echo Falha ao atualizar a branch %COMMON_BRANCH%. Saindo.
        goto end
    )

    rem Executar o build do common
    start cmd /k "mvn clean install -Padobe-public,autoInstallPackage,autoInstallBundle -Daem.port=4502 && pause"
    if errorlevel 1 (
        echo Falha ao executar o build do common. Saindo.
        goto end
    )

    echo Extraindo a versao do pom.xml
    set "VERSION="

    for /f "tokens=1,* delims=<>" %%a in ('findstr /i "<version>" "%COMMON_DIR%\pom.xml"') do (
        if not defined VERSION (
            set "temp=%%b"
            set "temp=!temp: =!"
            set "VERSION=!temp:version>=!"
            set "VERSION=!VERSION:</version>=!"
            for /f "delims=<> tokens=1" %%c in ("!VERSION!") do set "VERSION=%%c"
        )
    )

    if not defined VERSION (
        echo Nao foi possivel extrair a versao do pom.xml. Saindo.
        goto end
    )
)


cd /d "%PROJECT_PATH%"
if errorlevel 1 (
    echo Falha ao acessar o diretorio do projeto. Saindo.
    goto end
)

set /p BRANCH_NAME="Digite o nome da branch do projeto principal que deseja buildar: "
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
    echo Opcao de build invalida. Saindo.
    goto end
)

echo Iniciando o build.
start cmd /k "cd /d %PROJECT_PATH% && %BUILD_COMMAND% && pause"

:end
echo Script finalizado.
pause
