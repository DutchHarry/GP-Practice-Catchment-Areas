$NumberOfProcesses = 1
$ProcessNumber = 1

$Inputfile = "S:\_ue\GPPall.txt"
$OutputFile= "S:\_ue\GPPall2catchment.txt"

$host.ui.RawUI.WindowTitle = "GPP catchment Process $ProcessNumber"
$ProgressPreference = 'SilentlyContinue' #stop the flickering of invoke-webrequest
$nl = [Environment]::NewLine
$Delimiter ="¬"
$Data = $null
$Counter = 0

  # get number of postcodes
  $CountOfGPP = 0
  $Reader = New-Object IO.StreamReader $inputfile
  while($Reader.ReadLine() -ne $null){ $CountOfGPP++ }
  $Reader.Close()  
  # per process
  $CountOfGPP = $CountOfGPP+$NumberOfProcesses # to make sure none is left out
  [int]$RecordsPerProcess = $CountOfGPP/$NumberOfProcesses
  $RangeStart = ($ProcessNumber-1)*$RecordsPerProcess
  $RangeEnd = $ProcessNumber*$RecordsPerProcess - 1


  $Reader = New-Object System.IO.StreamReader($inputfile)
  #cycle towards start GPP
  $j= 0
  While ($j -lt $RangeStart){
    $gpp = $reader.ReadLine()
    $j++    
  }
  While ($RangeEnd -ge $RangeStart){
    # get the GPP data
    $gpp = $reader.ReadLine()
    # process GPP start
      if ($gpp -eq $null){Return}
      #$gpp = "Y05307" # empty
      #$gpp = "K82019" #single
      #$gpp ="K82038" #multiple
      $url = "https://www.primarycare.nhs.uk/publicfn/catchment.aspx?oc=$gpp&h=700&w=900&if=0"
      # relevant data is in this bit
      $pagedata = (Invoke-Webrequest -Uri $url).Scripts[2].InnerHTML
      If ($pagedata -eq $null){
      	# do nothing; GPP apparently doesn't exist on site
      }else{
      	
      	# initially tried this; which is good if you want to do all further processing in SQL
#      	# replace CRLF; grab relevant part; put back CRLF (for SQL processing)
#        $data = "$data$gpp$nl" + ($pagedata.ToString().Replace("`r`n","£n£") -replace "^ .+poly1(.+)function isPointInPoly.+ $",'poly1$1').Replace("£n£","`r`n")  + "$nl"
        # but you can also limit the data here first
        # transform string in lines and grab the relevant ones
        # easy approach probably using 'poly1'
#        $pagelines = $pagedata.Split("`n") | % { if($_ -match "poly1") {$_} } | Select -First 1
        # but you might want to go to the bottom of it with grabbing all different areas and get lines with var CCn (n from 0 to number of defined areas)
        $pagelines = $pagedata.Split("`n") | % { if($_ -match "CC") {$_} } 
        $pagelines = $pagelines | Select -First ($pagelines.Count-2) #-Index 0 # 0 has the coordinates; remainder has coloring which as 'meaning' in a few cases
#        $pagelines
        # finally you could also try working with this        
#        $pagelines = $pagedata.Split("`n") | % { if($_ -match "bounds.extend") {$_} } | Select -First 2

        # data in $pagelines; add GPP code, delimiter ¬ and write to file
        # somehow a space before subsequent lines is introduced; don't know why
        $pagelines = $pagelines | % {"$gpp¬" + $_.Replace("`t","").Replace("    ","")}
        $pagelines = $pagelines.Replace("`r ","`r`n")
        $data = "$data$pagelines"
      }
      $counter++
      If ($counter%10 -eq 0){ # so changes at least once per minute
        Write-Host "Process $ProcessNumber : $counter"
        # if you get memory problems:
      Add-Content $outputfile "$data" #adds another CRLF, so need to strip these later
        $data = $null
      }
    # process GPP end
    $RangeStart++
  }
  Add-Content $outputfile "$data"
  $reader.Close()
  $reader = $null

#$gpp = "F84096"
#$url = "https://www.primarycare.nhs.uk/publicfn/catchment.aspx?oc=$gpp&h=700&w=900&if=0"
#$page = Invoke-Webrequest -Uri $url
#$page.Scripts[2].InnerHTML

#($page.Scripts[2].InnerHTML).ToString().Replace("`r`n","") -replace 'var.+var point(.+)map.fitBounds(latlngbounds);.+^','$1'
#($page.Scripts[2].InnerHTML).ToString().Replace("`r`n","").Replace("  "," ").Replace("  "," ").Replace("  "," ").Replace("  "," ").Replace("  "," ").Replace("  "," ") -replace ' var.+point(.+)map.fitBounds.+} $','$1'
#($page.Scripts[2].InnerHTML).ToString().Replace("`r`n","").Replace("  "," ").Replace("  "," ").Replace("  "," ").Replace("  "," ").Replace("  "," ").Replace("  "," ") `
#-replace "^ .+poly1(.+)function isPointInPoly.+} $",'poly1$1'
#$page.Scripts[2].InnerHTML.ToString().Replace("`r`n","") -replace "^ .+poly1(.+)function isPointInPoly.+ $",'poly1$1'



