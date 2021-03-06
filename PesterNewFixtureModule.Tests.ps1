<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script

Import-Module $here\EncodingHelper\EncodingHelper.psd1

#region Describe "New-FixtureModule"
Describe "New-FixtureModule" {
    BEFOREALL {
        $location = $PWD
        $a = New-TemporaryFile
        $dir = ".\$($a.basename)"
        $targDir = new-item -ItemType Directory -Path $dir -Verbose}

#    BeforeEach {cd $location}
    It "New-FixtureModule creates one .tests.ps1 file."{
        New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' 
        (Get-ChildItem "$($targDir.FullName)\bob.tests.ps1" | Measure-Object).Count | Should Be 1
    }

    It "New-FixtureModule creates one .psm1 file."{
        New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' 
        (Get-ChildItem "$($targDir.FullName)\bob.psm1" | Measure-Object).Count | Should Be 1
    }

    It "New-FixtureModule creates one .psd1 file."{
        New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' 
        (Get-ChildItem "$($targDir.FullName)\bob.psd1" | Measure-Object).Count | Should Be 1
    }

    It "New-FixtureModule creates one .psd1 file that is UTF8 encoded."{
        New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' 
        (Get-ChildItem "$($targDir.FullName)\bob.psd1" | Get-FileEncoding).Encoding | Should Be 'UTF8'
    }

    It "New-FixtureModule creates one .Tests.ps1 file that is UTF8 encoded."{
        New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' 
        (Get-ChildItem "$($targDir.FullName)\bob.Tests.ps1" | Get-FileEncoding).Encoding | Should Be 'UTF8'
    }

    It "New-FixtureModule creates three files and can take a relative path."{
        New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' 
        (Get-ChildItem $targDir.FullName | Measure-Object).Count | Should Be 3
    }

    It "New-FixtureModule creates three files and echos them back to output."{
        (New-FixtureModule -Path $dir -Name 'bob' -Author 'TheAuthor' | Measure-Object).Count | Should Be 3
    }

    It "New-FixtureModule creates three files and can take '.\'."{
        cd "$location\$dir"
        New-FixtureModule -Path '.\' -Name 'bob' -Author 'TheAuthor'
        (Get-ChildItem -Filter "bob*" | Measure-Object).Count | Should Be 3
    }

    It "New-FixtureModule creates three files and can default to '.\' for omitted path."{
        cd "$location\$dir"
        New-FixtureModule -Name 'bob' -Author 'TheAuthor'
        (Get-ChildItem -Filter "bob*" | Measure-Object).Count | Should Be 3
    }
    <#Beware of addint tests after these ones, as I had a miserable time debugging my change-directory problems.#>

    AfterEach {(Get-ChildItem $targDir.FullName) | Remove-Item -Verbose:$false}

    AfterAll {
    cd $location
    Remove-Item $($targDir.FullName) -Recurse -Verbose}
}
#endregion Describe "New-FixtureModule"

