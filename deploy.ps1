# Script de deployment para test-app
# Uso: .\deploy.ps1

param(
    [string]$ProjectPath = "C:\NetProjects\test-app",
    [string]$PublishPath = "C:\inetpub\test-app",
    [string]$AppPoolName = "test-app-pool",
    [string]$SiteName = "test-app"
)

Write-Host "Iniciando deployment..." -ForegroundColor Cyan

# 1) Limpiar compilaciones anteriores
Write-Host "Limpiando compilaciones anteriores..." -ForegroundColor Yellow
Remove-Item -Path "$ProjectPath\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$ProjectPath\obj" -Recurse -Force -ErrorAction SilentlyContinue

# 2) Compilar el proyecto
Write-Host "Compilando proyecto..." -ForegroundColor Yellow
& "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" `
    "$ProjectPath\InstanaTestApp.csproj" `
    /p:Configuration=Release `
    /p:Platform=AnyCPU `
    /verbosity:minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Compilacion fallida" -ForegroundColor Red
    exit 1
}

Write-Host "Compilacion exitosa" -ForegroundColor Green

# 3) Detener el App Pool
Write-Host "Deteniendo App Pool: $AppPoolName..." -ForegroundColor Yellow
Stop-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 4) Limpiar la carpeta de publicacion
Write-Host "Limpiando carpeta de publicacion: $PublishPath..." -ForegroundColor Yellow
Remove-Item -Path "$PublishPath\*" -Recurse -Force -ErrorAction SilentlyContinue

# 5) Copiar archivos compilados
Write-Host "Copiando archivos a $PublishPath..." -ForegroundColor Yellow
Copy-Item -Path "$ProjectPath\*" `
    -Destination $PublishPath `
    -Recurse -Force `
    -Exclude @("bin","obj",".git*",".vs","*.ps1")

# 6) Iniciar el App Pool
Write-Host "Iniciando App Pool: $AppPoolName..." -ForegroundColor Yellow
Start-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

Write-Host "Deployment completado exitosamente" -ForegroundColor Green
Write-Host "Sitio disponible en: http://localhost:8080/$SiteName" -ForegroundColor Cyan
