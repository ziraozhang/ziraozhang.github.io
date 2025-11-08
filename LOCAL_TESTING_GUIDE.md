# How to Test the Website Locally

This is a **built React application** (static site) that's ready to be served. You don't need to build anything - just serve the existing files.

## Quick Options

### Option 1: Using Python (if installed)
```powershell
# Python 3
python -m http.server 8000

# Then open: http://localhost:8000
```

### Option 2: Using Node.js http-server (if Node.js is installed)
```powershell
# Install globally (one time)
npm install -g http-server

# Run the server
http-server -p 8000

# Then open: http://localhost:8000
```

### Option 3: Using VS Code Live Server Extension
1. Install the "Live Server" extension in VS Code
2. Right-click on `index.html`
3. Select "Open with Live Server"

### Option 4: Using PowerShell (Simple HTTP Server)
```powershell
# Navigate to the project directory
cd D:\ZeroWebsite\ziraozhang.github.io

# Start a simple HTTP server using PowerShell
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "Server running at http://localhost:8000/"
Write-Host "Press Ctrl+C to stop"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $localPath = $request.Url.LocalPath
    if ($localPath -eq "/") { $localPath = "/index.html" }
    
    $filePath = Join-Path $PWD $localPath.TrimStart('/')
    $filePath = $filePath.Replace('/', '\')
    
    if (Test-Path $filePath -PathType Leaf) {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentLength64 = $content.Length
        $response.ContentType = [System.Web.MimeMapping]::GetMimeMapping($filePath)
        $response.OutputStream.Write($content, 0, $content.Length)
    } else {
        $response.StatusCode = 404
    }
    
    $response.Close()
}
```

### Option 5: Install and Use a Simple Server Tool

**Using npx (if you have Node.js):**
```powershell
npx http-server -p 8000
```

**Or install a standalone tool:**
- Download and use [MAMP](https://www.mamp.info/) (includes Apache)
- Use [XAMPP](https://www.apachefriends.org/) (includes Apache)
- Use [IIS Express](https://www.iis.net/downloads/microsoft/iis-express) (Windows built-in)

## Important Notes

1. **Always use a proper HTTP server** - Don't just open `index.html` in a browser directly (file:// protocol) because:
   - The React Router may not work correctly
   - Service worker may not function
   - Some features require HTTP protocol

2. **Port 8000** - You can use any available port (3000, 8080, etc.)

3. **Access the site** - Once the server is running, open your browser and go to:
   ```
   http://localhost:8000
   ```

4. **Stop the server** - Press `Ctrl+C` in the terminal where the server is running

## Recommended: Quick PowerShell Server Script

I can create a simple PowerShell script that you can double-click to start the server. Would you like me to create that?

