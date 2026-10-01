# Script completo: Compilar, Publicar y Probar en IIS
# Uso: .\full-deploy.ps1

param(
    [string]$ProjectPath = "C:\NetProjects\test-app",
    [string]$PublishPath = "C:\inetpub\test-app",
    [string]$AppPoolName = "test-app-pool",
    [string]$SiteName = "test-app",
    [int]$Port = 8080
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "INICIO DE DEPLOYMENT COMPLETO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1) Verificar que el proyecto existe
Write-Host "`n[1] Verificando proyecto..." -ForegroundColor Yellow
if (!(Test-Path "$ProjectPath\InstanaTestApp.csproj")) {
    Write-Host "ERROR: No existe $ProjectPath\InstanaTestApp.csproj" -ForegroundColor Red
    exit 1
}
Write-Host "Proyecto encontrado" -ForegroundColor Green

# 2) Limpiar compilaciones anteriores
Write-Host "`n[2] Limpiando compilaciones anteriores..." -ForegroundColor Yellow
Remove-Item -Path "$ProjectPath\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$ProjectPath\obj" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Limpieza completada" -ForegroundColor Green

# 3) Compilar el proyecto
Write-Host "`n[3] Compilando proyecto..." -ForegroundColor Yellow
& "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" `
    "$ProjectPath\InstanaTestApp.csproj" `
    /p:Configuration=Release `
    /p:Platform=AnyCPU

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Compilacion fallida" -ForegroundColor Red
    exit 1
}
Write-Host "Compilacion exitosa" -ForegroundColor Green

# 4) Verificar que se genero el DLL
Write-Host "`n[4] Verificando que se genero la DLL..." -ForegroundColor Yellow
$dllPath = "$ProjectPath\bin\InstanaTestApp.dll"
if (!(Test-Path $dllPath)) {
    Write-Host "ERROR: No se genero $dllPath" -ForegroundColor Red
    Write-Host "Contenido de $ProjectPath\bin:" -ForegroundColor Gray
    Get-ChildItem "$ProjectPath\bin" -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "DLL encontrado: $dllPath" -ForegroundColor Green

# 5) Detener el App Pool
Write-Host "`n[5] Deteniendo App Pool: $AppPoolName..." -ForegroundColor Yellow
Stop-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "App Pool detenido" -ForegroundColor Green

# 6) Crear la carpeta de publicacion si no existe
Write-Host "`n[6] Preparando carpeta de publicacion..." -ForegroundColor Yellow
if (!(Test-Path $PublishPath)) {
    New-Item -Path $PublishPath -ItemType Directory -Force | Out-Null
}
Write-Host "Carpeta lista: $PublishPath" -ForegroundColor Green

# 7) Limpiar la carpeta de publicacion
Write-Host "`n[7] Limpiando carpeta de publicacion..." -ForegroundColor Yellow
Remove-Item -Path "$PublishPath\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Carpeta limpiada" -ForegroundColor Green

# 8) Copiar archivos del proyecto (excepto bin, obj, .git)
Write-Host "`n[8] Copiando archivos del proyecto..." -ForegroundColor Yellow
Copy-Item -Path "$ProjectPath\*" `
    -Destination $PublishPath `
    -Recurse -Force `
    -Exclude @("bin","obj",".git*",".vs","*.ps1")
Write-Host "Archivos copiados" -ForegroundColor Green

# 9) Copiar la carpeta bin compilada
Write-Host "`n[9] Copiando DLL compilada..." -ForegroundColor Yellow
Copy-Item -Path "$ProjectPath\bin\*" `
    -Destination "$PublishPath\bin" `
    -Recurse -Force
Write-Host "DLL copiada" -ForegroundColor Green

# 10) Arrancar el App Pool
Write-Host "`n[10] Iniciando App Pool: $AppPoolName..." -ForegroundColor Yellow
Start-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Write-Host "App Pool iniciado" -ForegroundColor Green

# 11) Verificar la ruta fisica del sitio
Write-Host "`n[11] Verificando configuracion del sitio..." -ForegroundColor Yellow
$site = Get-Website -Name $SiteName -ErrorAction SilentlyContinue
if ($null -eq $site) {
    Write-Host "ERROR: Sitio $SiteName no existe en IIS" -ForegroundColor Red
    exit 1
}
$actualPath = $site.PhysicalPath
Write-Host "Ruta configurada en IIS: $actualPath" -ForegroundColor Gray
if ($actualPath -ne $PublishPath) {
    Write-Host "ADVERTENCIA: La ruta no coincide. Esperaba: $PublishPath" -ForegroundColor Orange
}

# 12) Verificar que la carpeta publicada tiene archivos
Write-Host "`n[12] Verificando archivos publicados..." -ForegroundColor Yellow
$files = Get-ChildItem $PublishPath -ErrorAction SilentlyContinue
if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "ERROR: La carpeta publicada esta vacia" -ForegroundColor Red
    exit 1
}
Write-Host "Archivos publicados ($($files.Count)):" -ForegroundColor Green
Get-ChildItem $PublishPath | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

# 13) Verificar que existe el bin publicado
Write-Host "`n[13] Verificando DLL publicada..." -ForegroundColor Yellow
if (!(Test-Path "$PublishPath\bin\InstanaTestApp.dll")) {
    Write-Host "ERROR: DLL no se copio a $PublishPath\bin" -ForegroundColor Red
    Write-Host "Contenido de $PublishPath\bin:" -ForegroundColor Gray
    Get-ChildItem "$PublishPath\bin" -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "DLL publicada OK" -ForegroundColor Green

# 14) Probar la URL
Write-Host "`n[14] Probando acceso a la aplicacion..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$Port" -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "Aplicacion respondiendo (HTTP 200)" -ForegroundColor Green
    } else {
        Write-Host "Respuesta HTTP: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "No se pudo conectar a la URL (esto es normal si la app aun carga)" -ForegroundColor Yellow
    Write-Host "Verificar en: http://localhost:$Port" -ForegroundColor Cyan
}

# 15) Abrir el navegador
Write-Host "`n[15] Abriendo navegador..." -ForegroundColor Yellow
Start-Process "http://localhost:$Port"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DEPLOYMENT COMPLETADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "URL: http://localhost:$Port" -ForegroundColor Green
Write-Host "Ruta fisica: $PublishPath" -ForegroundColor Green
Write-Host "App Pool: $AppPoolName" -ForegroundColor Green
