# Script to set up environment variables for deployment
param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = 'prod',
    
    [Parameter(Mandatory=$false)]
    [string]$Location = 'centralus',
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-webapp-102-lz"
)

# Verify Azure PowerShell connection
$context = Get-AzContext
if (-not $context) {
    Write-Host "Not connected to Azure. Please run 'Connect-AzAccount' first." -ForegroundColor Red
    exit 1
}

# Set environment variables for deployment
$env:AZURE_RG = $ResourceGroupName
$env:AZURE_LOCATION = $Location
$env:AZURE_ENVIRONMENT = $Environment

# Get storage account name from the resource group
try {
    $storageAccounts = Get-AzStorageAccount -ResourceGroupName $env:AZURE_RG
    $primaryStorage = $storageAccounts | Where-Object { $_.StorageAccountName -like "pstor*" } | Select-Object -First 1
    if ($primaryStorage) {
        $env:AZURE_STORAGE_ACCOUNT = $primaryStorage.StorageAccountName
    } else {
        Write-Warning "Primary storage account not found. Please deploy the infrastructure first."
    }
} catch {
    Write-Warning "Error getting storage accounts: $_"
}

# Get DNS zone name from the resource group
try {
    $dnsZone = Get-AzDnsZone -ResourceGroupName $env:AZURE_RG | Select-Object -First 1
    if ($dnsZone) {
        $env:AZURE_DNS_ZONE = $dnsZone.Name
    } else {
        Write-Warning "DNS zone not found. Please deploy the infrastructure first."
    }
} catch {
    Write-Warning "Error getting DNS zone: $_"
}

# Display current environment settings
Write-Host "`nCurrent Environment Settings:" -ForegroundColor Green
Write-Host "Resource Group: $env:AZURE_RG"
Write-Host "Location: $env:AZURE_LOCATION"
Write-Host "Environment: $env:AZURE_ENVIRONMENT"
Write-Host "Storage Account: $env:AZURE_STORAGE_ACCOUNT"
Write-Host "DNS Zone: $env:AZURE_DNS_ZONE"
