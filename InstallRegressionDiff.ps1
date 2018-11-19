If ($env:PSModulePath -like "*C:\Program Files\WindowsPowerShell\Modules*")
{
    $moduleDestination = "C:\Program Files\WindowsPowerShell\Modules"
} Else
{
    $paths = $env:PSModulePath -split ';'
    $moduleDestination = $paths[0]
}
Get-ChildItem -Path $moduleDestination -Include "RegressionDiff*" -Recurse | Remove-Item -Recurse
Copy-Item $PSScriptRoot\..\RegressionDiff -Destination $moduleDestination -Recurse

Write-Host "Done! The next time you restart Powershell, youll be able to run RegressionDiff and EditTeam from anywhere! Don't forget to look at the readme for more info about how it!"
