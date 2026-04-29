param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("root", "cert")]
    [string]$Type,
    
    [string]$Name = "server",
    
    [string]$Dns = "localhost",
    
    [string]$CaKey,
    
    [string]$CaCert
)

$ErrorActionPreference = "Stop"

if ($Type -eq "root") {
    Write-Host "Generating Root CA..." -ForegroundColor Cyan
    openssl genrsa -out "${Name}_rootCA.key" 4096
    openssl req -x509 -new -nodes -key "${Name}_rootCA.key" -sha256 -days 3650 -out "${Name}_rootCA.crt" `
        -subj "/CN=${Name}-Root-CA/O=MA-Agents/C=US"
    Write-Host "Root CA created: ${Name}_rootCA.crt" -ForegroundColor Green

} elseif ($Type -eq "cert") {
    if (-not $CaKey -or -not $CaCert) {
        Write-Host "Generating standalone self-signed certificate..." -ForegroundColor Cyan
        openssl req -x509 -newnodes -days 365 -newkey rsa:2048 `
            -keyout "${Name}.key" -out "${Name}.crt" `
            -subj "/CN=${Dns}/O=MA-Agents" `
            -addext "subjectAltName = DNS:${Dns}"
    } else {
        Write-Host "Generating certificate signed by CA..." -ForegroundColor Cyan
        openssl genrsa -out "${Name}.key" 2048
        openssl req -new -key "${Name}.key" -out "${Name}.csr" -subj "/CN=${Dns}/O=MA-Agents"
        
        # Extension file for SAN
        "subjectAltName = DNS:${Dns}" | Out-File -FilePath "${Name}.ext" -Encoding ascii
        
        openssl x509 -req -in "${Name}.csr" -CA "$CaCert" -CAkey "$CaKey" -CAcreateserial `
            -out "${Name}.crt" -days 365 -sha256 -extfile "${Name}.ext"
        
        Remove-Item "${Name}.csr", "${Name}.ext" -ErrorAction SilentlyContinue
    }
    Write-Host "Certificate created: ${Name}.crt" -ForegroundColor Green
}
