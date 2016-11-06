<#
Purpose:
	Download any other stuff from www.primarycare.nhs.uk

Needs login


Needs (un)commenting relevant lines for:
#$files
#$downloaddirectory
#$source
#$destination

Downloaddirectories MUST exist!

#>

#change window title
$host.ui.RawUI.WindowTitle = "www.primarycare.nhs.uk data extraction"
$ProgressPreference = 'SilentlyContinue' #stop the flickering of invoke-webrequest


#$downloaddirectory = "S:\d\www.primarycare.nhs.uk\GPP_Profiles"  #must exist
#$downloaddirectory = "S:\d\www.primarycare.nhs.uk\GPP_Achievements"  #must exist
#$downloaddirectory = "S:\d\www.primarycare.nhs.uk\GPP_Performance"  #must exist
#$downloaddirectory = "S:\d\www.primarycare.nhs.uk\CCG_PracticeData"  #must exist
#$downloaddirectory = "S:\d\www.primarycare.nhs.uk\CCG_Uncovered_postcodes"  #must exist
#$downloaddirectory = "S:\d\www.primarycare.nhs.uk\CCG_Map"  #must exist
# ccg level files
#$files = "S:\_ue\ccg code list.txt"
# practice level files
#$files = "S:\_ue\gppall.txt"                         # file with GPP codes
#$files = "S:\_ue\GPmissingAll.txt"                         # file with GPP codes


# LOGIN and getting session for the cookies handling
$credentials = $host.UI.PromptForCredential('Your Credentials', 'Enter Credentials', '', '')
$r = Invoke-WebRequest 'https://www.primarycare.nhs.uk/' -SessionVariable my_session
# can get the names by going to site in browser, and right-click 'Inspect element'
$form = $r.Forms[0]
$form.fields['uname'] = $credentials.UserName
$form.fields['upass'] = $credentials.GetNetworkCredential().Password
$r = Invoke-WebRequest -Uri ('https://www.primarycare.nhs.uk/' + $form.Action) -WebSession $my_session -Method POST -Body $form.Fields


$reader = [System.IO.File]::OpenText($files)

try {
for(;;) {
$line = $reader.ReadLine()
if ($line -eq $null) { break }
# process the line
try {  
# get the file
#$source = "https://www.primarycare.nhs.uk/private/gphli/module_practice/practice_profile_csv.aspx?gp=$line"
#$destination = "$downloaddirectory\$line"+"_Profile.csv"
#$source = "https://www.primarycare.nhs.uk/private/gphli/module_practice/practice_achievement_csv.aspx?gp=$line"
#$destination = "$downloaddirectory\$line"+"_Achievement.csv"
#$source = "https://www.primarycare.nhs.uk/private/gpos/module_practiceachievement/performance_global_csv.aspx?gp=$line"
#$destination = "$downloaddirectory\"+"Performance_Heatmap_"+$line+".csv"
#$source = "https://www.primarycare.nhs.uk/private/gphli/module_default/default_download_csv.aspx?type=3&org=$line"
#$destination = "$downloaddirectory\$line"+"_PracticeData.csv"
#$source = "https://www.primarycare.nhs.uk/private/gpos/module_ccgachievement/ccg_performance_uncovered.aspx?ccg=$line"
#$source = "https://www.primarycare.nhs.uk/private/gpos/module_ccgachievement/ccg_performance_uncovered.aspx?ccg=$line"
#$destination = "$downloaddirectory\"+"Uncovered_Postcodes_"+$line+".csv"
#$source = "https://www.primarycare.nhs.uk/private/gpos/module_ccgachievement/CCGMap/"+"$line"+".gif"
#$destination = "$downloaddirectory\"+"$line"+".gif"
#$r = Invoke-WebRequest -Uri ($source + $form.Action) -OutFile $destination -WebSession $my_session -Method POST -Body $form.Fields
$r = Invoke-WebRequest -Uri $source -OutFile $destination -WebSession $my_session

# write line to console
Write-Host "$line"
}catch{
$errorcode = $_.Exception.Response.StatusCode.Value__ 
Write-Host ("ErrorCode  : $errorcode") 
Write-Host ("On address : $source") 
}
} # for loop
} # try  
finally {
$reader.Close()
}




