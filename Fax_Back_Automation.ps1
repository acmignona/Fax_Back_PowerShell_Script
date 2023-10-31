#######################################################
# This script is intended to work with Zetafax Server #
# This script allows you to automatically fax back    #
# Senders that send to a specified fax number         #
# within a specified fax mailbox.                     #
#                                                     #
#                         - Anthony Mignona, 2023     #
#######################################################

#----------------------------#
#         [REQUIRED]         #
#----------------------------#
# Please fill in variables   #
# to your need below.        #
##############################

$manual_substitute_numbers = Import-Csv -Path "configs\substitutes.csv"

$zsubmit_path = "$(Get-Location)\zsubmit" # Enter the UNC path to thhe ZSUBMIT folder, found in Zetafax Configuration. 

$faxlines = @(   
   # Create a custom object per fax folder or number. 
   [pscustomobject]@{
        ServerName='TESTSERVER'; # What is the hostname of the Zetafax server? 
        z_fax_user='TESTING'; # What is the receiving Zetafax username? 
        z_in_path ="$(Get-Location)\z-in"; # The path will likely be \\<SERVERNAME>\zfax\<USER>\z-in
        Trigger_Number="11111111111"; # If we detect this number in the CTL files, we will fax back the originator
        fax_back_document = "files\example.pdf" # Enter path of the document you'd like to fax back. 
        sub_file = "files\example.sub" # Enter the path of the corresponding .sub file that this script will use as a template. 
    }
)

$logs = [pscustomobject]@{
    processed='logs\processed.txt'; 
    faxedback='logs\faxed_back_log.txt'; 
    timestamp='logs\time_log.txt';
    errors='logs\errors.txt'
    logsenders = 'logs\log_sender_numbers.csv'
    manual_substitute_log = 'logs\manual_substitute_log.txt'
}

#-----------------------------------#
#        [END OF REQUIRED]          #
#-----------------------------------#
# No need to modify anything below, #
# unless you have a need to enhance #
# this script.                      #
#####################################


$starttime = Get-Date 

foreach($faxline in $faxlines){
    
    # Grab all CTLs within the folder that are < an hour old
    $files = Get-ChildItem -Path $faxline.z_in_path -Filter *.ctl | Where-Object { $_.Name -ne "MSGDIR.CTL" -and $_.LastWriteTime -ge (Get-Date).AddHours(-3) }
    write-host "$($faxline.z_in_path) Total: $(($files | Measure-object ).count)" -BackgroundColor DarkRed -ForegroundColor White
    
    # Create temporary directory if needed 
    if (-not (Test-Path -Path ((Split-Path -Path $faxline.fax_back_document) + "\temp") -PathType Container)) {
        New-Item -Path ((Split-Path -Path $faxline.fax_back_document) + "\temp") -ItemType Directory -Verbose
    }

    # Process each CTL
    foreach($file in $files){
        try{
            # Reset all fields per iteration. 
            $zetafax_files = [PSCustomObject]@{ ctl_basename = ""; ctl_fullpath = ""; ctl_content = ""; ctl_messageID = ""; ctl_cli_number = ""; ctl_csid = ""; sub_basename =""; sub_fullpath =""; pdf_fullpath = ""; tmp_fullpath = ""; tmp_base = ""; process_ID= ""; fax_number = ""; fax_number_type = ""; zsubmit_doc_path = ""}

            # Enter fields for this iteration.
            $zetafax_files.ctl_basename = "$($file.BaseName).ctl" 
            $zetafax_files.ctl_fullpath = "$($file.Directory)\$($file.BaseName).ctl"; 
            $zetafax_files.ctl_content = get-content -path $file.fullname;
            $zetafax_files.ctl_messageID = $zetafax_files.ctl_content | Select-String -Pattern "MessageID";
            $zetafax_files.ctl_cli_number = ($zetafax_files.ctl_content | Select-String -Pattern "CLI") -replace '[^\d]', ''
            $zetafax_files.ctl_csid = ($zetafax_files.ctl_content | Select-String -Pattern "CSID") -replace '[^\d]', ''
            $zetafax_files.sub_basename = (Get-Item -Path $faxline.sub_file).Name;
            $zetafax_files.sub_fullpath = $faxline.sub_file;
            $zetafax_files.pdf_fullpath = $faxline.fax_back_document;
            $zetafax_files.tmp_fullpath = ((Split-Path -Path $faxline.fax_back_document) + "\temp");
            $zetafax_files.tmp_base = "";
            $zetafax_files.process_ID= "$($faxline.ServerName)_$($faxline.z_fax_user)_$($faxline.Trigger_Number)_$($zetafax_files.ctl_messageID -replace 'MessageID: ','')";
            $zetafax_files.fax_number = ($zetafax_files.ctl_cli_number | Select-String -Pattern '\b\d{11}\b' | ForEach-Object { $_.Matches.Value })
            $zetafax_files.fax_number_type = "CLI";
            $zetafax_files.zsubmit_doc_path = "$($zsubmit_path)\$(Split-Path $faxline.fax_back_document -Leaf)"
            
            write-host $zetafax_files.zsubmit_doc_path

            # If the ProcessID is found in the Processed log, skip this document. 
            if((get-content -path $logs.processed) -contains $zetafax_files.process_ID){
                write-host  "[SKIP]: ALREADY PROCESSED - FILE:$($file.name) - PROCESSID:$($zetafax_files.process_ID)" -ForegroundColor White -BackgroundColor DarkBlue 
                continue 
            }

            # If we cant find the TFN in the file, skip to the next file
            if(-not($zetafax_files.ctl_content -match $faxline.Trigger_Number)) {
                write-host "[SKIP]: TRIGGER NUMBER NOT DETECTED " -BackgroundColor darkred -ForegroundColor white
                Add-Content -Path $logs.processed -Value $zetafax_files.process_ID
                continue 
            }

            # CLI Substitution 
            if($manual_substitute_numbers.CLI -contains $zetafax_files.fax_number){    
                foreach($row in $manual_substitute_numbers){
                    
                    $substitute_method = ""
                    
                    # Determine substitution method
                    if($row.CLI -contains $zetafax_files.fax_number){
                        $substitute_method = $row.Substitute_Method
                    }

                    # Substitution Method: CLI. Find CLI row and replace with Substitute CLI
                    if($substitute_method -eq "CLI"){
                        Write-Host "CLI: Replacing $($zetafax_files.fax_number) with $($row.Substitute_CLI)." -BackgroundColor Red -ForegroundColor White
                        $zetafax_files.fax_number_type = "Substitute_CLI"
                        $zetafax_files.fax_number = $row.Substitute_CLI
                        break

                    }

                    # # Substitution Method: CLI_and_CSID. Find row with matching CLI and CSID and replace with Substitute CLI
                    if($substitute_method -eq "CLI_and_CSID" -and $zetafax_files.ctl_csid -contains $row.CSID){
                        Write-Host "CLI_and_CSID: Replacing $($zetafax_files.fax_number) with $($row.Substitute_CLI)." -BackgroundColor Red -ForegroundColor White
                        $zetafax_files.fax_number_type = "Substitute_CLI"
                        $zetafax_files.fax_number = $row.Substitute_CLI
                        break
                    }
                }
            }
            
            # CLI substitution using just CLI AND CSID as trigger logic
            if($manual_substitute_numbers.CLI -contains $zetafax_files.fax_number){    
                foreach($row in $manual_substitute_numbers){
                    if($row.CLI -contains $zetafax_files.fax_number -and $row.CSID -contains $zetafax_files.ctl_csid){
                        Write-Host "CLI_AND_CSID: Replacing $($zetafax_files.fax_number) with $($row.Substitute_CLI)." -BackgroundColor Red -ForegroundColor White
                        $zetafax_files.fax_number_type = "Substitute_CLI_and_CSID"
                        $zetafax_files.fax_number = $row.Substitute_CLI
                    }
                }
            } 
            
            # Create a temporary sub
            $zetafax_files.tmp_base = "FaxBackAutomation_$($faxline.z_fax_user)_$(Get-Date -Format "yyyyMMddHHmmssffff").sub"
            $zetafax_files.tmp_fullpath = "$($zetafax_files.tmp_fullpath)\$($zetafax_files.tmp_base)" 
            Copy-Item $zetafax_files.sub_fullpath -Destination $zetafax_files.tmp_fullpath -Verbose
        
            # Update temporary sub file with Sender's Number
            $content = get-content -Path $zetafax_files.tmp_fullpath
            $content = $content -replace "Fax: REPLACE_ME_1234567890", ("FAX: $($zetafax_files.fax_number)") | Set-Content -Path $zetafax_files.tmp_fullpath
            $content = get-content -Path $zetafax_files.tmp_fullpath
            $content = $content -replace "REPLACE_ME_WITH_FULL_FILE_PATH", ("$($zsubmit_path)\$(Split-Path $faxline.fax_back_document -Leaf)") | Set-Content -Path $zetafax_files.tmp_fullpath

            # Move PDF and Sub File to Z-Submit for Processing
            Copy-Item $zetafax_files.pdf_fullpath -Destination $zsubmit_path -Force -Verbose
            Move-Item $zetafax_files.tmp_fullpath -Destination $zsubmit_path -Verbose
            Add-Content -Path $logs.faxedback -Value "$($starttime) - $($zetafax_files)"
            Add-Content -Path $logs.processed -Value $zetafax_files.process_ID
            Add-Content -path $logs.manual_substitute_log -Value "($(get-date -format MM/dd/yyyy_HH:mm)) - Sending fax back to originator CLI: $($zetafax_files.ctl_cli_number) with substitute number:$($zetafax_files.fax_number). Logic method: $($substitute_method)" -Verbose
            
            # Add the sender's number to the Senders Log
            if((get-content -path $logs.logsenders) -notcontains $zetafax_files.fax_number){
                Add-Content -Path $logs.logsenders -Value "$($zetafax_files.fax_number),$($zetafax_files.fax_number_type)"
            }

        } catch {
            Add-Content -Path $logs.processed -Value $zetafax_files.process_ID
            Add-Content -Path $logs.errors -Value "$($starttime) - $($file.FullName)"
            write-host "ERROR!: FILE:$($file.name)" -ForegroundColor White -BackgroundColor DarkRed
            Continue
        }
    }
}

# Script Run Time Calculation
$endtime = Get-Date
$timeSpan = $endtime - $starttime
$minutes = [Math]::Floor($timeSpan.TotalMinutes)
$seconds = $timeSpan.Seconds
$proctime = "$($minutes) minutes and $($seconds) seconds"
add-content -Path $logs.timestamp -Value "($(get-date -format MM/dd/yyyy_HH:mm)) - Process time: $($proctime)"

# Maintain the log file size.
$content = get-content -Path $logs.processed -tail 15000; $content | Set-Content -Path $logs.processed -Force
$content = get-content $logs.faxedback -Tail 2000; $content | Set-Content -Path $logs.faxedback -Force
$content = get-content $logs.timestamp -Tail 500; $content | Set-Content -Path $logs.timestamp -Force
$content = get-content $logs.errors -Tail 100; $content | Set-Content -Path $logs.errors -Force
$content = get-content $logs.logsenders -Tail 10000; $content | Set-Content -Path $logs.logsenders -Force
$content = get-content $logs.manual_substitute_log -Tail 500; $content | Set-Content -Path $logs.manual_substitute_log -Force
