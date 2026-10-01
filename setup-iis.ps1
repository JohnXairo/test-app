# Script de configuracion de IIS para test-app
# Uso: .\setup-iis.ps1

param(
    [string]$PublishPath = "C:\inetpub\test-app",
    [string]$AppPoolName = "test-app-pool",
    [string]$SiteName = "test-app",
    [int]$Port = 8080
)

Write-Host "Configurando IIS para test-app..." -ForegroundColor Cyan

# 1) Crear la carpeta de publicacion si no existe
if (!(Test-Path $PublishPath)) {
    Write-Host "Creando carpeta: $PublishPath" -ForegroundColor Yellow
    New-Item -Path $PublishPath -ItemType Directory -Force | Out-Null
}

# 2) Crear el App Pool
Write-Host "Creando App Pool: $AppPoolName..." -ForegroundColor Yellow
$appPool = Get-IISAppPool -Name $AppPoolName -ErrorAction SilentlyContinue

if ($null -eq $appPool) {
    New-WebAppPool -Name $AppPoolName -Force | Out-Null
    $appPool = Get-IISAppPool -Name $AppPoolName
    $appPool.ManagedRuntimeVersion = "v4.0"
    $appPool.ManagedPipelineMode = "Integrated"
    $appPool | Set-Item
    Write-Host "App Pool creado: $AppPoolName (CLR v4.0)" -ForegroundColor Green
} else {
    Write-Host "App Pool ya existe: $AppPoolName" -ForegroundColor Gray
}

# 3) Crear el sitio web
Write-Host "Creando sitio web: $SiteName..." -ForegroundColor Yellow
$site = Get-Website -Name $SiteName -ErrorAction SilentlyContinue

if ($null -eq $site) {
    New-Website `
        -Name $SiteName `
        -PhysicalPath $PublishPath `
        -ApplicationPool $AppPoolName `
        -Port $Port `
        -Force | Out-Null
    Write-Host "Sitio creado: $SiteName en puerto $Port" -ForegroundColor Green
} else {
    Write-Host "Sitio ya existe: $SiteName" -ForegroundColor Gray
    # Asegurar que use el App Pool correcto
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name applicationPool -Value $AppPoolName
    Write-Host "App Pool asignado: $AppPoolName" -ForegroundColor Green
}

# 4) Dar permisos a la carpeta
Write-Host "Configurando permisos en: $PublishPath..." -ForegroundColor Yellow
$acl = Get-Acl $PublishPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "IIS AppPool\$AppPoolName",
    "Modify",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($rule)
Set-Acl -Path $PublishPath -AclObject $acl
Write-Host "Permisos configurados" -ForegroundColor Green

# 5) Iniciar el sitio
Write-Host "Iniciando sitio: $SiteName..." -ForegroundColor Yellow
Start-Website -Name $SiteName -ErrorAction SilentlyContinue
Start-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "Acceder a: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "1. Clonar el repositorio: git clone https://github.com/JohnXairo/test-app $PublishPath" -ForegroundColor Gray
Write-Host "2. Ejecutar: .\deploy.ps1 -ProjectPath $PublishPath" -ForegroundColor Gray
