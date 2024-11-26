# Get environment variables or use parameters
$ResourceGroupName = if ($env:AZURE_RG) { $env:AZURE_RG } else { Read-Host -Prompt "Enter Resource Group Name" }
$StorageAccountName = if ($env:AZURE_STORAGE_ACCOUNT) { $env:AZURE_STORAGE_ACCOUNT } else { Read-Host -Prompt "Enter Storage Account Name" }
$DnsZoneName = if ($env:AZURE_DNS_ZONE) { $env:AZURE_DNS_ZONE } else { Read-Host -Prompt "Enter DNS Zone Name" }

# Verify Azure connection
$context = Get-AzContext
if (-not $context) {
    Write-Host "Not connected to Azure. Please run 'Connect-AzAccount' first." -ForegroundColor Red
    exit 1
}

Write-Host "Using the following settings:" -ForegroundColor Green
Write-Host "Resource Group: $ResourceGroupName"
Write-Host "Storage Account: $StorageAccountName"
Write-Host "DNS Zone: $DnsZoneName"

try {
    # Get the storage account
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    if (-not $storageAccount) {
        throw "Storage account not found"
    }

    # Get the verification token directly from the storage account
    $verificationToken = $storageAccount.CustomDomainVerificationToken

    if ($verificationToken) {
        Write-Host "Retrieved verification token: $verificationToken" -ForegroundColor Green

        # Update the TXT record in the DNS zone
        $txtRecordSet = @{
            Name = "@"
            ResourceGroupName = $ResourceGroupName
            ZoneName = $DnsZoneName
            RecordType = "TXT"
            Ttl = 3600
            DnsRecords = @(
                @{
                    Value = @("MS=$verificationToken")
                }
            )
        }

        Set-AzDnsRecordSet @txtRecordSet
        Write-Host "Successfully updated TXT record with verification token" -ForegroundColor Green
    } else {
        throw "Could not retrieve verification token from storage account"
    }
} catch {
    Write-Error "Error: $_"
    Write-Error $_.Exception.Message
    exit 1
}
