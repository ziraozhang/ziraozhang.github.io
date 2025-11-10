# Simple PowerShell HTTP Server for Local Testing
# Double-click this file or run: .\start-server-simple.ps1

$port = 8000
$url = "http://localhost:$port/"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Local Web Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server URL: $url" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Check if port is already in use
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "Port $port is already in use. Trying port 8001..." -ForegroundColor Yellow
    $port = 8001
    $url = "http://localhost:$port/"
}

# PowerShell HTTP Listener
Write-Host "Starting PowerShell HTTP Server..." -ForegroundColor Green
Write-Host ""

# Check if running as administrator (required for HttpListener on some systems)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Note: If you get permission errors, try running PowerShell as Administrator" -ForegroundColor Yellow
    Write-Host ""
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

try {
    $listener.Start()
    Write-Host "✓ Server is running at: $url" -ForegroundColor Green
    Write-Host "✓ Open this URL in your browser to view the site" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "Error starting server: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Try running PowerShell as Administrator, or use a different port" -ForegroundColor Yellow
    exit 1
}

# Function to get MIME type
function Get-MimeType {
    param([string]$filePath)
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $mimeTypes = @{
        '.html' = 'text/html; charset=utf-8'
        '.css'  = 'text/css; charset=utf-8'
        '.js'   = 'application/javascript; charset=utf-8'
        '.json' = 'application/json; charset=utf-8'
        '.png'  = 'image/png'
        '.jpg'  = 'image/jpeg'
        '.jpeg' = 'image/jpeg'
        '.gif'  = 'image/gif'
        '.svg'  = 'image/svg+xml'
        '.pdf'  = 'application/pdf'
        '.ico'  = 'image/x-icon'
        '.map'  = 'application/json'
    }
    if ($mimeTypes.ContainsKey($ext)) {
        return $mimeTypes[$ext]
    }
    return 'application/octet-stream'
}

# Start browser automatically
Start-Process $url

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/") { 
            $localPath = "/index.html" 
        }
        
        # Convert URL path to file system path
        $filePath = Join-Path $PSScriptRoot $localPath.TrimStart('/')
        $filePath = $filePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
        
        if (Test-Path $filePath -PathType Leaf) {
            try {
                $content = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $content.Length
                $response.ContentType = Get-MimeType $filePath
                $response.StatusCode = 200
                $response.OutputStream.Write($content, 0, $content.Length)
                Write-Host "$($request.HttpMethod) $localPath - 200" -ForegroundColor Green
            } catch {
                $response.StatusCode = 500
                $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("Internal Server Error")
                $response.ContentLength64 = $errorMsg.Length
                $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
                Write-Host "$($request.HttpMethod) $localPath - 500 (Error: $($_.Exception.Message))" -ForegroundColor Red
            }
        } else {
            # For React Router - serve index.html for all routes (SPA routing)
            $indexPath = Join-Path $PSScriptRoot "index.html"
            if (Test-Path $indexPath) {
                $content = [System.IO.File]::ReadAllBytes($indexPath)
                $response.ContentLength64 = $content.Length
                $response.ContentType = 'text/html; charset=utf-8'
                $response.StatusCode = 200
                $response.OutputStream.Write($content, 0, $content.Length)
                Write-Host "$($request.HttpMethod) $localPath - 200 (served index.html for SPA route)" -ForegroundColor Yellow
            } else {
                $response.StatusCode = 404
                $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("File Not Found")
                $response.ContentLength64 = $errorMsg.Length
                $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
                Write-Host "$($request.HttpMethod) $localPath - 404" -ForegroundColor Red
            }
        }
        
        $response.Close()
    }
} catch {
    Write-Host ""
    Write-Host "Server error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    Write-Host ""
    Write-Host "Server stopped." -ForegroundColor Yellow
}


