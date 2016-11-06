$NumberOfProcesses = 1
$ProcessNumber = 1

$Inputfile = "S:\_ue\PostCodesTest.txt"
$OutputFile= "S:\_ue\PostCodesTest2GPP.txt"
<#
Todo:
  split into processes but use same file so by counter
  https://blogs.technet.microsoft.com/uktechnet/2016/06/20/parallel-processing-with-powershell/
  
Purpose:
  Get GP practices that would accept registrations from certain postcodes
  
Input
  A file with a few English postcodes (Scotland, Wales and NI practices aren't included )

Output:
  If postcode exists, you get a nice JSON response, e.g. 
  {"GPs": [{"OrgCode": "K82042", "OrgName": "WHITCHURCH SURGERY", "Latitude": 51.881882, "Longitude": -0.842359 },{"OrgCode": "K82068", "OrgName": "WADDESDON SURGERY", "Latitude": 51.844241, "Longitude": -0.917693 }]}
  otherwise you get:
  "PostCode not found or no Practices linked to PostCode"
  
  The script concatenates all outputs after prefixing with "$postcode" and "$delimiter", and adds CRLF ($nl)
  
  So depending on how you want to progress you'll have to clean the outputfile
  I don't, as I take it apart in SQL 2016
  
  In SQL we'll BULK INSERT using the delimiter ¬
  After that we use SQL 2016 JSON capabilities to transform all in a table from postcode to GPP code
  There are more authoritative sources for the other data elements
  Luckily we're not interested in the other data, as the format doesn't conform to proper JSON when latitude or longitude data is missing.

Runtime:
  1400k+ postcodes
  35k+ per hour
  thus 40 hours runtime
  fairly low traffic, so split into multiple processes
  Split into 10 processes -> <5 hours
  reality closer to 10

1441619
1315210 / 10 = 131522
 126409

#>

$host.ui.RawUI.WindowTitle = "Process $ProcessNumber Postcode 2 GPP"
$ProgressPreference = 'SilentlyContinue' #stop the flickering of invoke-webrequest
$nl = [Environment]::NewLine
$Delimiter ="¬"
$Data = $null
$Counter = 0



  # get number of postcodes
  $CountOfPostcodes = 0
  $Reader = New-Object IO.StreamReader $inputfile
  while($Reader.ReadLine() -ne $null){ $CountOfPostcodes++ }
  $Reader.Close()  
  # per process
  $CountOfPostcodes = $CountOfPostcodes+$NumberOfProcesses # to make sure none is left out
  [int]$RecordsPerProcess = $CountOfPostcodes/$NumberOfProcesses
  $RangeStart = ($ProcessNumber-1)*$RecordsPerProcess
  $RangeEnd = $ProcessNumber*$RecordsPerProcess - 1


  $Reader = New-Object System.IO.StreamReader($inputfile)
  #cycle towards start postcode
  $j= 0
  While ($j -lt $RangeStart){
    $postcode = $reader.ReadLine()
    $j++    
  }
  While ($RangeEnd -ge $RangeStart){
    # get the postcode data
    $postcode = $reader.ReadLine()
    # process postcode start
      if ($postcode -eq $null){Return}
      $url = "https://www.primarycare.nhs.uk/publicfn/mapping/postcodelookup.ashx?auth=D4E13042&postcode=$postcode"
      $data = "$data$postcode$delimiter" + (Invoke-Webrequest -Uri $url).Content + "$nl"
      $counter++
      If ($counter%1000 -eq 0){ # so changes at least once per minute
        Write-Host "Process $ProcessNumber : $counter"
        # if you get memory problems:
        Add-Content $outputfile "$data" #adds another CRLF, so need to strip these later
        $data = $null
      }
    # process postcode end
    $RangeStart++
  }
  Add-Content $outputfile "$data"
  $reader.Close()
  $reader = $null




