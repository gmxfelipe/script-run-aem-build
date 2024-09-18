param (
    [string]$type = "file"
)

Add-Type -AssemblyName System.Windows.Forms

if ($type -eq "file") {
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Filter = "JAR Files (*.jar)|*.jar|All Files (*.*)|*.*"
    $fileBrowser.Title = "Selecione o arquivo JAR"

    if ($fileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Write-Output $fileBrowser.FileName
    } else {
        Write-Error "Nenhum arquivo foi selecionado"
        exit 1
    }
} elseif ($type -eq "folder") {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Selecione a pasta CRX"

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Write-Output $folderBrowser.SelectedPath
    } else {
        Write-Error "Nenhuma pasta foi selecionada"
        exit 1
    }
} else {
    Write-Error "Tipo de seleção inválido"
    exit 1
}
