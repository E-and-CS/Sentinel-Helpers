## Heavily based upon:
## https://gist.githubusercontent.com/JamesDLD/e5dc67a08e169acf9514462edd2c0212/raw/9a68f848b9c636765421564228afe93e20e357f6/network-worbook.ps1

## Variable
param(
  [Parameter(Mandatory = $true)][string]$SubscriptionName,
  [Parameter(Mandatory = $true)][string]$ResourceGroup,
  [Parameter(Mandatory = $true)][string]$Workspace,
  [Parameter(Mandatory = $true)][string]$Uri,
  [Parameter(Mandatory = $true)][string]$WorkbookName,
  [Parameter(Mandatory = $true)][string]$WorkbookType,
  [Parameter(Mandatory = $true)][string]$WorkbookGallery
)

## Options
## Data from https://github.com/microsoft/Application-Insights-Workbooks/blob/cbca30b004e98a8942130e932987dbc706d70eba/Documentation/Programmatically.md#existing-galleries
$galleryOptions = @{}
$galleryOptions["Azure Monitor"] = @(
  "workbook"
  "vm-insights"
)
$galleryOptions["microsoft.operationalinsights/workspaces"] = @("workbook")
$galleryOptions["microsoft.insights/component"] = @(
  "workbook"
  "tsg"
  "usage"
)
$galleryOptions["Microsoft.ContainerService/managedClusters"] = @("workbook")
$galleryOptions["microsoft.resources/subscriptions/resourcegroups"] = @("workbook")
$galleryOptions["microsoft.aadiam/tenant"] = @("workbook")
$galleryOptions["microsoft.compute/virtualmachines"] = @("insights")
$galleryOptions["microsoft.compute/virtualmachinescalesets"] = @("insights")

## "Constants" - these will not change.
$TemplateUri = "https://raw.githubusercontent.com/E-and-CS/Sentinel-Helpers/5606cd8869cb50bbc6333aad00d41b262a25e69a/DeployWorkbookTemplate.json"

## Parsed values
$WorkbookContent = Invoke-RestMethod -Uri $Uri

## Validation
if ($WorkbookGallery -in $galleryOptions && $WorkbookType -in $galleryOptions[$WorkbookGallery]) {
  ## Connectivity
  # Login first with Connect-AzAccount if not using Cloud Shell
  $AzureRmContext = Get-AzSubscription -SubscriptionName $SubscriptionName | Set-AzContext -ErrorAction Stop
  Select-AzSubscription -Name $SubscriptionName -Context $AzureRmContext -Force -ErrorAction Stop

  ## Action
  Write-Host "Deploying : $WorkbookType-$WorkbookName in the resource group : $ResourceGroup" -ForegroundColor Cyan
  New-AzResourceGroupDeployment -Name $(("$WorkbookType-$WorkbookName").replace(' ', '')) `
    -ResourceGroupName $ResourceGroup `
    -TemplateUri $TemplateUri `
    -workbookName $WorkbookName `
    -workbookType $WorkbookType `
    -workbookGallery $WorkbookGallery `
    -workbookContent ($WorkbookContent | ConvertTo-Json -Depth 20) `
    -Confirm -ErrorAction Stop
}
