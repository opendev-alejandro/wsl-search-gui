function IsWSL2Installed {
    $wslVersion = wsl -l 2>$null
    if ($wslVersion -contains "Windows Subsystem for Linux Distributions:") {
        return $true
    } else {
        return $false
    }
}

function IsPDFGrepInstalled {
    $pdfgrepInstalled = wsl -e pdfgrep --version 2>$null
    if ($pdfgrepInstalled[0] -match "This is pdfgrep version") {
        return $true
    } else {
        return $false
    }
}