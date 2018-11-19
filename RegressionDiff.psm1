# Output Field Separator is space by default, change to newline
$OFS = "`r`n"

function Setup{
    # Output Field Separator is space by default, change to newline
    $OFS = "`r`n"

    $regressionDiffDirectory = "$env:USERPROFILE\Documents\RegressionDiff\"
    
    If ( -NOT (Test-Path $regressionDiffDirectory))
    {
        Write-Host "`nIt looks like this is your first time running this script! I just want to set-up some stuff for you...`n"
        New-Item -ItemType "directory" -Path $regressionDiffDirectory | Out-Null
    }

    If ( -NOT (Test-Path "$regressionDiffDirectory\config"))
    {
        New-Item -ItemType "file" -Path $regressionDiffDirectory -Name "config" | Out-Null
        Write-Host "`nYou don't have a team configured yet! Let's do that now!`n"
        EditTeam
    }
}

function RegressionDiff{
    param
    (
        [Parameter(Mandatory=$True, HelpMessage='Previous Branch? (eg. origin/branchname or tagname)')]
        [string]$before,

        [Parameter(HelpMessage='Current Branch? (default: HEAD)')]
        [string]$after = "HEAD"
    )

    # Output Field Separator is space by default, change to newline
    $OFS = "`r`n"
    Setup

    $regressionDiffDirectory = "$env:USERPROFILE\Documents\RegressionDiff\"
    $team = Get-Content -Path "$regressionDiffDirectory\config"
    $teamString = $team -join "`n`t"
    Write-Host "`nYour team:`n`t$teamString"
    
    $authorBlob = "\(" + ($team -join "\)\|\(") + "\)"
    
    $commits = git log "$before..$after" `
        --author="$authorBlob" `
        --committer="$authorBlob" `
        --cherry-pick `
        --pretty=format:'%H,%P,%an,%cn,\"%s\"'

    $proj, $repo = Select-String -Path .\.git\config -Pattern 'url = ssh://[^/]+/(\w+)/(\w+)\.git' | %{ $_.Matches[0].Groups[1].Value, $_.Matches[0].Groups[2].Value}
    
    #$commits | Out-File relcommit.txt
    $commits = $commits -replace '(\w{40}),(\w{40}),', '$1,$2,,'
    $commits = $commits -replace '(\w{40}) ', '$1,'
    $commits = $commits -replace '(?<=^|,)(\w{40})(?=,)', '"=HYPERLINK(""https://git.kcura.com/projects/PROJ/repos/REPO/commits/$1"",""$1"")"'
    $commits = $commits -replace '/PROJ/', "/$proj/"
    $commits = $commits -replace '/REPO/', "/$repo/"
    $commits = "Commit Hash, Parent Hash, Parent2 Hash, Author, Committer, Summary`r`n" + $commits
    $commits | Out-File relcommit.csv -Encoding ascii
    
    $jiras = $commits | Select-String -Pattern '\w+-\d+' -AllMatches | %{ $_.Matches } | %{ $_.Value.ToUpper() } | select -Unique
    $jiras = $jiras -replace '(\w+-\d+)', '"=HYPERLINK(""https://jira.kcura.com/browse/$1"",""$1"")"'
    $jiras | Out-File jiras.csv -Encoding ascii

    Invoke-Item relcommit.csv
    Invoke-Item jiras.csv
}

function EditTeam{
    # Output Field Separator is space by default, change to newline
    $OFS = "`r`n"

    $regressionDiffDirectory = "$env:USERPROFILE\Documents\RegressionDiff\"
    
    $response = ""
    Do
    {
        [System.Collections.ArrayList]$team = @()
        Foreach ($teammate in Get-Content -Path "$regressionDiffDirectory\config")
        {
            $team.Add($teammate) | Out-Null
        }
        $teamString = $team -join "`n`t"
        Write-Host "`nYour team:`n`t$teamString"
        $response = Read-Host -Prompt "[a]dd, [d]elete, [q]uit"

        If ($response -eq "a")
        {
            $newName = Read-Host -Prompt "What is the name of the user you want to add? (Must match their git username exactly)"
            If ($newName -ne "")
            {
                $team.Add($newName) | Out-Null
                $team | Out-File $regressionDiffDirectory\config
            }
        }
        If ($response -eq "d")
        {
            $delName = Read-Host -Prompt "Who do you want me to delete? Remember, I'm just a computer, you have to type it exact!"
            If ($team.Contains($delName))
            {
                $team.Remove($delName) | Out-Null
                $team | Out-File $regressionDiffDirectory\config
            }
        }
    } While ($response -ne "q")
    Write-Host "Cool, exiting! I'll use this team next time you run RegressionDiff."
}
