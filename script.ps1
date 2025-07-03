Import-Module $PSScriptRoot\functions.psm1 -Force
# debug option
$debugMode = $false

function Start-Search {
    param (
        [string]$path,
        [string]$Term,
        [string]$Type,
        [hashtable]$Options
    )

    # Validate parameters

    # Check if path is provided if not set to current directory
    if (-not $path) {
        $path = Get-Location
    } elseif (-not (Test-Path $path)) {
        [System.Windows.Forms.MessageBox]::Show("The specified path does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    if (-not $Term) {
        [System.Windows.Forms.MessageBox]::Show("Search term cannot be empty.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    # if pdfgrep is selected, validate that the recursiveCB option is set
    if ($Type -eq "PDF" -and -not $Options.Recursive) {
        [System.Windows.Forms.MessageBox]::Show("Recursive option must be enabled for PDF search.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    #convert path from windows to wsl path
    #debug mesage box to show path
    if ($debugMode) {
        [System.Windows.Forms.MessageBox]::Show("Converting path to WSL format: $path")
    }

    $path = $path -replace '^([A-Za-z]):', '/mnt/$1'
    $path = $path.ToLower()
    $path = $path -replace '\\', '/'


    if ($debugMode) {
        [System.Windows.Forms.MessageBox]::Show("Converted path: $path")
    }

    # Construct the command based on search type
    switch ($Type) {
        "PlainText" {
            $command = "grep -r"
            if ($Options.CaseSensitive) { $command += " -i" }
            if ($Options.Recursive) { $command += " -R" }
            if ($Options.LineNumbers) { $command += " -n" }
            if ($Options.WholeWords) { $command += " -w" }
            if ($Options.IgnoreBinary) { $command += " -I" }
            $command += " --exclude-dir='\.git'"
            $command += " '$Term' '$path'"
        }
        "PDF" {
            $command = "pdfgrep"
            if ($Options.CaseSensitive) { $command += " -i" }
            if ($Options.Recursive) { $command += " -r" }
            if ($Options.LineNumbers) { $command += " -n" }
            if ($Options.WholeWords) { $command += " -w" }
            $command += " '$Term' '$path'"
        }
        "File" {
            # add case sensitivity and recursiveCB options
            $command = "find '$path' -type f"
            if ($Options.CaseSensitive) { $command += " -iname" }
            $command += " -not -path '*/\.git*'"
            $command += " -name '*$Term*'"
        }
    }

    if ($debugMode) {
        # add message box to show command
        [System.Windows.Forms.MessageBox]::Show("Executing command:`n$command")
    }
    # Execute the command in WSL2
    $outputFile = "search_results.txt"
    wsl -e bash -c "$command" > $outputFile 2>&1

    # inform the user that search results are saved to a file
    $resultBox = [System.Windows.Forms.MessageBox]::Show("Search completed. Results saved to $outputFile", "Search Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

    #open the output file in the default text editor
    if ($resultBox -eq [System.Windows.Forms.DialogResult]::OK) {
        Start-Process $outputFile
    }
}

function RunGui {
    # Configure the GUI
    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object System.Windows.Forms.Form
    
    $form.Text = "Search Tool"
    $form.Width = 400
    $form.Height = 400
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $searchTermLB = New-Object System.Windows.Forms.Label
    $searchTermLB.Text = "Enter search term:"
    $searchTermLB.AutoSize = $true
    $searchTermLB.Top = 10
    $searchTermLB.Left = 10

    $searchTermTB = New-Object System.Windows.Forms.TextBox
    $searchTermTB.Top = 30
    $searchTermTB.Left = 10
    $searchTermTB.Width = 200

    $searchTypeGB = New-Object System.Windows.Forms.GroupBox
    $searchTypeGB.Text = "Search Type"
    $searchTypeGB.Top = 110
    $searchTypeGB.Left = 10
    $searchTypeGB.Width = 180
    $searchTypeGB.Height = 150

    $plainTxtTypeRB = New-Object System.Windows.Forms.RadioButton
    $plainTxtTypeRB.Text = "Plain text Search"
    $plainTxtTypeRB.Top = 20
    $plainTxtTypeRB.Left = 10
    $plainTxtTypeRB.Width = 150
    $plainTxtTypeRB.Height = 20
    $plainTxtTypeRB.Checked = $true  # Set Plain Text Search as default

    $pdfTxtTypeRB = New-Object System.Windows.Forms.RadioButton
    $pdfTxtTypeRB.Text = "PDF Search"
    $pdfTxtTypeRB.Top = 40
    $pdfTxtTypeRB.Left = 10
    $pdfTxtTypeRB.Width = 150
    $pdfTxtTypeRB.Height = 20

    $fileTypeRB = New-Object System.Windows.Forms.RadioButton
    $fileTypeRB.Text = "File Search"
    $fileTypeRB.Top = 60
    $fileTypeRB.Left = 10
    $fileTypeRB.Width = 150
    $fileTypeRB.Height = 20

    $searchOptsGB = New-Object System.Windows.Forms.GroupBox
    $searchOptsGB.Text = "Search Options"
    $searchOptsGB.Top = 110
    $searchOptsGB.Left = 190
    $searchOptsGB.Width = 180
    $searchOptsGB.Height = 150

    $caseSensCB = New-Object System.Windows.Forms.CheckBox
    $caseSensCB.Text = "Case Sensitive"
    $caseSensCB.Top = 20
    $caseSensCB.Left = 10
    $caseSensCB.Width = 150
    $caseSensCB.Height = 20

    $recursiveCB = New-Object System.Windows.Forms.CheckBox
    $recursiveCB.Text = "Recursive"
    $recursiveCB.Top = 40
    $recursiveCB.Left = 10
    $recursiveCB.Width = 150
    $recursiveCB.Height = 20
    $recursiveCB.Checked = $true  # Set Recursive as default

    $lineNumbersCB = New-Object System.Windows.Forms.CheckBox
    $lineNumbersCB.Text = "Line Numbers"
    $lineNumbersCB.Top = 60
    $lineNumbersCB.Left = 10
    $lineNumbersCB.Width = 150
    $lineNumbersCB.Height = 20

    $wholeWordsCB = New-Object System.Windows.Forms.CheckBox
    $wholeWordsCB.Text = "Whole Words"
    $wholeWordsCB.Top = 80
    $wholeWordsCB.Left = 10
    $wholeWordsCB.Width = 150
    $wholeWordsCB.Height = 20

    $ignoreBinCB = New-Object System.Windows.Forms.CheckBox
    $ignoreBinCB.Text = "Ignore Binary Files"
    $ignoreBinCB.Top = 100
    $ignoreBinCB.Left = 10
    $ignoreBinCB.Width = 150
    $ignoreBinCB.Height = 20
    $ignoreBinCB.Checked = $true  # Set Ignore Binary as default


    # add option to select path
    $searchDirLB = New-Object System.Windows.Forms.Label
    $searchDirLB.Text = "Directory to search:"
    $searchDirLB.AutoSize = $true
    $searchDirLB.Top = 60
    $searchDirLB.Left = 10

    $searchDirTB = New-Object System.Windows.Forms.TextBox
    $searchDirTB.Top = 80
    $searchDirTB.Left = 10
    $searchDirTB.Width = 200

    $searchDirBT = New-Object System.Windows.Forms.Button
    $searchDirBT.Text = "Browse..."
    $searchDirBT.Top = 80
    $searchDirBT.Left = 220
    $searchDirBT.Width = 100

    $searchDirBT.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $searchDirTB.Text = $folderBrowser.SelectedPath
        }
    })

    #add option to close with escape key
    $form.Add_KeyDown({
        if ($_.KeyCode -eq "Escape") {
            $form.Close()
        }
    })
    $form.KeyPreview = $true

    #add debug write-output
    if ($debugMode) {
        Write-Output "GUI initialized in debug mode. Waiting for user input..."
    }

    # add button in right bottom corner to execute search
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Search"
    $button.Width = 100
    $button.Height = 30
    $button.Top = $form.Height - 80
    $button.Left = $form.Width - 120
    $button.Add_Click({
        if ($debugMode) {
            [System.Windows.Forms.MessageBox]::Show("Search started")
        }

        # Handle search button click
        $searchTerm = $searchTermTB.Text
        $path = $searchDirTB.Text
        $searchType = if ($plainTxtTypeRB.Checked) { "PlainText" } elseif ($pdfTxtTypeRB.Checked) { "PDF" } else { "File" }
        $options = @{
            CaseSensitive = $caseSensCB.Checked
            Recursive = $recursiveCB.Checked
            LineNumbers = $lineNumbersCB.Checked
            WholeWords = $wholeWordsCB.Checked
            IgnoreBinary = $ignoreBinCB.Checked
        }

        #add message box to show search parameters
        if ($debugMode) {
            [System.Windows.Forms.MessageBox]::Show("Search Parameters:`nPath: $path`nTerm: $searchTerm`nType: $searchType`nOptions: $($options | Out-String)")
        }

        Start-Search -Path $path -Term $searchTerm -Type $searchType -Options $options
    })

    # Add controls to the form
    $form.Controls.Add($searchTermLB)
    $form.Controls.Add($searchTermTB)
    $form.Controls.Add($searchDirLB)
    $form.Controls.Add($searchDirTB)
    $form.Controls.Add($searchDirBT)
    $form.Controls.Add($searchTypeGB)
    $searchTypeGB.Controls.Add($plainTxtTypeRB)
    $searchTypeGB.Controls.Add($pdfTxtTypeRB)
    $searchTypeGB.Controls.Add($fileTypeRB)
    $searchOptsGB.Controls.Add($caseSensCB)
    $searchOptsGB.Controls.Add($recursiveCB)
    $searchOptsGB.Controls.Add($lineNumbersCB)
    $searchOptsGB.Controls.Add($wholeWordsCB)
    $searchOptsGB.Controls.Add($ignoreBinCB)
    $form.Controls.Add($searchOptsGB)
    $form.Controls.Add($button)

    $form.ShowDialog()
}

if ($debugMode) {
    Write-Output "Debug mode is enabled."
    Write-Output "Running script in debug mode..."
    RunGui
    exit 0
}

$tmpFlag = IsWSL2Installed
if (-not $tmpFlag) {
    Write-Output "WSL2 is not installed."
    Write-Output "Install WSL2 to run this script."
    Write-Output "You can install WSL2 by running the following command in PowerShell as Administrator:"
    Write-Output "wsl --install"
    Write-Output "After installation, restart your computer and run this script again."
    exit 1
} else {
    Write-Output "WSL2 is installed correctly."
    if (-not (IsPDFGrepInstalled)) {
        Write-Output "PDFGrep is not installed in WSL2."
        Write-Output "Install PDFGrep by running the following command in WSL2:"
        Write-Output "sudo apt install pdfgrep"
        exit 1
    } else {
        Write-Output "PDFGrep is installed correctly."
        Write-Output "Opening GUI..."
        RunGui
    }
}
