Function Get-NodeStats {
<#
.SYNOPSIS
    Retrieve stats for specified Node(s) 
    
.EXAMPLE
    Get-NodeStats -Address 'N.N.N.N'

.EXAMPLE    
    Get-Node | Where-Object { $_.address -like 'N.N.N.*' -or $_.name -like 'XXXXX*' } | Get-NodeStats | Select-Object -ExpandProperty 'serverside.curConns'
#>
    [cmdletBinding()]
    param (
        $F5Session=$Script:F5Session,

        [Alias('Node')]
        [Parameter(ParameterSetName='InputObject',ValueFromPipeline=$true)]
        [PSObject[]]$InputObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [PoshLTM.F5Address[]]$Address=[PoshLTM.F5Address]::Any,

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string[]]$Name='',

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Partition
    )
    begin {
        #Test that the F5 session is in a valid format
        Test-F5Session($F5Session)

        Write-Verbose "NB: Node names are case-specific."
    }
    process {
        switch($PSCmdLet.ParameterSetName) {
            InputObject {
                foreach($item in $InputObject) {
                    $URI = $F5Session.GetLink(($item.selfLink -replace '\?','/stats?'))
                    $JSON = Invoke-F5RestMethod -Method Get -Uri $URI -F5Session $F5Session
                    $JSON = Resolve-NestedStats -F5Session $F5Session -JSONData $JSON
                    
                    Invoke-NullCoalescing {$JSON.entries} {$JSON}
                }
            }
            default {
                Get-Node -Partition $Partition -Name $Name -Address $Address -F5session $F5Session | Get-NodeStats -F5session $F5Session
            }
        }
    }
}