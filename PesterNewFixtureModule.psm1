
Function New-FixtureModule {
PARAM (
[Parameter(Mandatory=$false)][ValidateScript({
            Write-Verbose "Testing $_ "
        
            IF (Test-Path -PathType Container -Path $_ ) 
                {$True}
            ELSE {
                Throw "Value '$_' is not a Directory."
            } 
        }<#End Script Validation#>
        )][Alias('Path')][String]$Directory = '.\'
,[Parameter(Mandatory=$true)][String]$name
,[Parameter(Mandatory=$true)][String]$Author
)
    <#Clean up directory by removing trailing slash so I know I will not have double slash problems.#>
            IF ($Directory.LastIndexOfAny('\/') + 1 -eq $Directory.Length) {
            $Directory = $Directory.Substring(0,$Directory.LastIndexOfAny('\/'))
            } <#End If#>
            <#Standard windows format#>
            $Directory = $Directory.Replace('/','\')


$Fixtures = New-Fixture -Path "$Directory\" -Name $name



$newHeader = @'
<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script
'@

$a = Get-Content $Fixtures[1].Fullname
$newHeader > $Fixtures[1].Fullname <#Yes, overwrite, because...#>
$a | Select-Object -Last ($a.Length - 3) >> $Fixtures[1].Fullname

New-ModuleManifest -Path "$Directory\$name.psd1" -RootModule $name -Author $Author -ModuleVersion 1.0
Convert-FileEncoding -FullName "$Directory\$name.psd1" -Encoding UTF8
Convert-FileEncoding -FullName "$Directory\$name.Tests.ps1" -Encoding UTF8

Get-ChildItem $Fixtures[0].fullname | ForEach-Object { Rename-Item $_.FullName -NewName "$($_.Basename).psm1" -PassThru}
Get-ChildItem $Fixtures[1].fullname 
Get-ChildItem "$Directory\$name.psd1"

}<#End New-FixtureModule#>

Export-ModuleMember -Function "New-FixtureModule"

