Param (
    $compP,
    $proP
    
)

$proURI = "http://$proP"

$compAPI = "http://"+$compP+"/"
#$compAPI = "http://"+$compAddr+":"+$compPort+"/"

# get active presentaion
$uri = $proURI + "/v1/presentation/active?chunked=false"
$x = Invoke-WebRequest -Uri $uri -UseBasicParsing

# convert presentation details from JSON
$groups = $(ConvertFrom-Json $($x.Content)).presentation.groups

# Get text for slides if exists
$textOfSlides = ForEach ($group in $groups) {

    $slides = $group.slides
    forEach ($slide in $slides) {

       $slide | ForEach-Object { $_.text }
       }
    }

$numButtons = 12
$maxSlides = $textOfSlides.count - 1
for (($i = 0); $i -lt $numButtons; $i++) {

    # fewer slides than buttons
    if ($i -gt $maxSlides) {
        try {
            $custVar = "PresText" + $($i+1)
            $uri = $compAPI + "set/custom-variable/"+$custVar+"?value="+ "no slide" 
            $null = Invoke-WebRequest -Uri $uri -UseBasicParsing
            }
        catch {}
    }

    # have text for button
    else {
        try {
            $custVar = "PresText" + $($i+1)
            $textOfSlides[$i] = $($textOfSlides[$i] -replace '[^a-zA-Z0-9 ]', '').Trim()
            
            ## Pastor just wants the number, not the text
            ##$uri = $compAPI + "set/custom-variable/"+$custVar+"?value="+ "$($i+1) "+$textOfSlides[$i] 
            $uri = $compAPI + "set/custom-variable/"+$custVar+"?value="+ "$($i+1) " #+$textOfSlides[$i] 
            $null = Invoke-WebRequest -Uri $uri -UseBasicParsing
            }
        catch {}
    }

   
}

