# ProPresenter Remote V 2.0.0
Simple remote to change which slide is displayed in the active ProPresenter presentation.  The remote is a Companion web page.

We use it for simple sequential presentations like a sermon.  (Not for going through songs.)  The ProPresenter operator selects the first slide in the sermon presentation so it displays in the audience screen.  The person presenting the sermon then goes to a website URL on their phone.  They can then select any of the first 12 slides in the presentation to display that slide.

Notice that the simple website remote does not have a function to switch presentations.  This is by design. 

## Example

This URL on a phone displays the screen below.

http<nolink>://192.168.1.106:8000/tablet3?cols=3&noconfigure=1&nofullscreen=1&pages=5
  
![Alt text](images/README/image-1.png)

Notes:

    - In the above example, 192.168.1.106 is the address of the computer running Companion.  You would need to change this to the address in your environment.
    - The current presentation has 8 slides.  (max supported is 12)
    - The active slide is the first one, shown in RED.
    - The recommended next slide is the second one, shown in GREEN.
    - Any numbered slide selected will make that the active slide.

## Dependencies

The following are dependencies for this solution:

 - BitFocus Companion v3.x.x softare.  https://bitfocus.io/companion
   - Uses a Generic HTTP module in Companion expecting the label "HTTP".
 - ProPresenter  7.x.x with a version that has the new API 2.
 - The IP address of the computers running ProPresenter and Companion need to have static IP addresses.
    - Typically the addresses are reserved in DHCP which always gives them the same IP address.  And the addresses are manually configured on the computers, so the computers no longer use DHCP.  (Outside the scope of this summary.)
    - The instructions work if Companion and ProPresenter run on the same computer or different computers.

### Validated Environment

The folowing details note where the code has been validated:

 - BitFocus Companion 3.1.1 installed on Windows 10 and Windows 10.
     - No known reason why this would not also work with Companion on other operating system but not tested.
 - ProPresenter 7.13 running on a MAC and Windows 10.

## How to Install
Please review [Assumptions](#assumptions).

### 0) Backup the Companion configuration
Backup the Companion configurtion.

Why? Because the steps here can have unexpected results and you need a backup to restore your configuration.  (I know because I wiped out my triggers and did not have a backup to fix it.)

### 1) Create Variables
Create the following custom variables in Companion with the corresponding startup values if specified.

| Custom Variable Name | Startup Value | Use |
|---|---|---|
| pr_pres | presentation| Hold current presentation |
| pr_lastpres | presentation | List of slides in presentation |
| pr_slides | 0 | Number of slides in presentation |
| pr_slideindex |  | active slide info |
| pr_slidenum | | index of slide info |

### 3) Create Generic HTTP Connection

In Companion, add a new "Generic: HTTP Requests" connection.

Edit the connection:
- Change the "Label" from "http_#" to "httpPR".
  - The specific name is not important but you need to remember it for createing buttons and triggers.
-  Set the base URL to http<nolink>://192.168.68.64:8080
   -  Replace the IP address (192.168.68.64) with the address of the computer running ProPresenter.
   -  Replace the port (8080) with the port used by ProPresenter
   -  Note: These can be found in ProPresenter in Preferences\Networking
-  Press "Save"


### 4) Create Buttons
The buttons can be created by either:
- Importing the button page automatically
- Manually entering the button page

Recommend importing the button page over manual process

#### 4.1) Import the button page automatically
The companion configuration for the button page is in companionExports\button_page.companionconfig.

On the Companion admin page, select the "Import / Export" tab then select "Import".

When propted, open the local copy of the "button_page.compaionconfig" file.

On the "Import Configuration" page:
- Under "Destination Page" on the right, select the page number of the page you want to replace.  (Rembmer the page number for creating the URL later.)
- Under "Link import connection with existing connections" at the bottom, select "httpPR".  (This is the example name used prevoiusly when createing a generic http connection.)

Press "Import to page #" at the bottom where "#" is the page number you selected.



#### 4.2) Manually enter the button page
Note: This is not needed if you imported the button page.
<details>
Pick a page that you are not using.  This example will use page 6.

This example use 12 buttons, but there is no restriction.

Creating 12 buttons on page 6:
- Remote buttons for slides 1, 2 and 3 are Companion buttons 6.1, 6.2, 6.3
- Remote buttons for slides 4, 5 and 6 are Companion buttons 6.9, 6.10, 6.11
- Remote buttons for slides 7, 8 and 9 are Companion buttons 6.17, 6.18, 6.19
- Remote buttons for slides 10, 11 and 12 are Companion buttons 6.25, 6.26, 6.27

Below are the settings for the buttons for slide 2.  Notice how most settings contain a value relative to the slide number (2,1,2,2,1,0,2).  Once a button is created it can be copied to another button slot and then you need to adjust the settings relative to the slide number.  (Easier to use the automated import.)

Button 6.2 for slide 2
```
Button text string
2
Font size
Auto
Text : <black>
BG  : <brown>
Topbar
Hide
Text
<center>
PNG
<center> 
Relative Delays  : enabled 
Progress  : Enabled
Rotary Actions  : disabled


Actions

Press actions
httpPR: GET 
Delay
0 ms
URI
/v1/presentation/focused/1/trigger
header input(JSON)
JSON Response Data Variable
None
JSON Stringify Result : Checked
 
Release actions
httpPR: GET 
Delay
15 ms
URI
/v1/presentation/slide_index?chunked=false
header input(JSON)
JSON Response Data Variable
A custom variable (pr_slideindex)
JSON Stringify Result : Checked
 


Feedbacks

internal: Variable: Check boolean expression
Change style based on a boolean expression
Expression
$(internal:custom_pr_slides)  >=2
Invert : not checked
Button text string
2
Change style properties
Text

internal: Variable: Check value 
Change style based on the value of a variable
Variable
A custom variable (internal:custom_pr_slidenum)
Operation
=
Value
1
Invert : not checked
BG : <Red>
Change style properties
Background

internal: Variable: Check value 
Change style based on the value of a variable
Variable
A custom variable (internal:custom_pr_slidenum)
Operation
=
Value
0
Invert : not checked
BG : <Green>
Change style properties
Background

internal: Variable: Check boolean expression 
Change style based on a boolean expression
Expression
$(internal:custom_pr_slides)  < 2
Invert : Not checked
Button text string
<blank>
BG : <Brown>
```
</details>

### 5) Create Triggers
The Triggers can be created by either:
- Importing the triggers automatically
- Manually entering the triggers

#### 5.1) Import the triggers automatically
The companion configuration for the button page is in companionExports\trigger_list.companionconfig.

On the Companion admin page, select the "Import / Export" tab then select "Import".

When propted, open the local copy of the "trigger_list.compaionconfig" file.

On the "Import Configuration" page:
- Select the "Triggers" tab.
- Under "Triggers" there should be 7 triggers selected with names that start with "pr ".
- Under "Select connection" at the bottom, select "httpPR".

WARNING: Choosing the wrong button will wipe out existing triggers!  (Do you have a backup?)
Press "Import (Append to existing)"
- NOT "Import (Replace Existing)" - this removes all existing triggers

#### 5.2) Manually enter the triggers
This section is only needed if one decides not to import the triggers.
<details>
Only the first 3 trigger are required for the remote to work.
The last 4 are an attempt to reduce polling when ProPresenter is off.

| Name | Use |
|----|---|
| pr Get presentation slideindex | every 3 seconds check if presentation of slide changed |
| pr Set lastpres_slides | Gets the number of slides in the active presentation |
| pr Set slide number | Gets the number of the active slide in the presentation |
| pr Start poll when connection OK | Start poll when connection status is OK |
| pr Stop poll when connection Error | Stop poll when connection status is Error |
| pr Stop poll on start up | Stop poll when Companion starts | 
| pr Poll for ProPresenter | 10 seconds, test ProPresenter connection.  (OK or Error) |

##### 5.2.1) pr Get presentation slideindex 
```
Name
pr Get presentation slideindex

Relative Delays   : Not checked

Events  
Time Interval
 
Interval (seconds)
3


Actions  
httpPR: GET
 
Delay
0 ms
URI
/v1/presentation/active?chunked=false
header input(JSON)
JSON Response Data Variable
A custom variable (pr_pres)
JSON Stringify Result : Checked
 

httpPR: GET
 
Delay
0 ms
URI
/v1/presentation/slide_index?chunked=false
header input(JSON)
JSON Response Data Variable
A custom variable (pr_slideindex)
JSON Stringify Result : Checked
```

##### 5.2.2) pr Set lastpres_slides 
```
Name : pr Set lastpres_slides

Relative Delays : enabled 

Events  
On variable change
 
Variable to watch
A custom variable (internal:custom_pr_pres)


Actions  
internal: Custom Variable: Set from a stored JSONresult via a JSONpath expression
 
Delay
0 ms

JSON Result Data Variable
A custom variable (pr_pres)

Path (like $.age)
presentation.groups[*].slides[*]

Target Variable
A custom variable (pr_lastpres)

internal: Custom Variable: Set from a stored JSONresult via a JSONpath expression
 
Delay
10 ms

JSON Result Data Variable
A custom variable (pr_lastpres)

Path (like $.age)
$.length

Target Variable
A custom variable (pr_slides)


httpPR: GET
 
Delay
0 ms

URI
/v1/presentation/slide_index?chunked=false

header input(JSON)

JSON Response Data Variable
A custom variable (pr_slideindex)

JSON Stringify Result
Checked

``` 


##### 5.2.3) pr Set slide number 
```
Name
pr Set slide number

Relative Delays : Not checked

Events  
On variable change
 
Variable to watch
A custom variable (internal:custom_pr_slideindex)


Actions  
internal: Custom Variable: Set from a stored JSONresult via a JSONpath expression
 
Delay
0 ms

JSON Result Data Variable
A custom variable (pr_slideindex)
Path (like $.age)
presentation_index.index
Target Variable
A custom variable (pr_slidenum)
```

##### 5.2.4) pr Start poll when connection OK
```
Name
pr Start poll when connection OK

Relative Delays : Not checked  

Events  
On condition becoming true
 

Condition  
internal: Connection: When matches specified status
 
Change style when a connection matches the specified status
Connection
httpPR
State
OK
Invert : Not checked
 

Actions  
internal: Trigger: Enable or disable trigger
 
Delay
0 ms
Trigger
pr Get presentation slideindex
Enable
Yes
```

##### 5.2.5) pr Stop poll when connection Error 

```
Name
pr Stop poll when connection Error

Relative Delays  : not checked

Events  
On condition becoming true
 

Condition  
internal: Connection: When matches specified status
 
Change style when a connection matches the specified status
Connection
httpPR
State
Error
Invert : Not checked
 

Actions  
internal: Trigger: Enable or disable trigger
 
Delay
0 ms
Trigger
pr Get presentation slideindex
Enable
No
```

##### 5.2.6) pr Stop poll on start up 

```
Name
pr Stop poll on start up

Relative Delays   : not checked

Events  
Startup
 
Delay (milliseconds)
10000


Actions  
internal: Trigger: Enable or disable trigger
 
Delay
0 ms
Trigger
pr Get presentation slideindex
Enable
No
```

##### 5.2.7) pr Poll for ProPresenter
```
Name
pr Poll for ProPresenter

Relative Delays   

Events  
Time Interval
 
Interval (seconds)
10


Actions  
httpPR: GET
 
Delay
0 ms
URI
/version
header input(JSON)
JSON Response Data Variable
None
JSON Stringify Result : Checked
```
</details>

### 6) Create ProPresenter Remote URL

1. In Companion GUI select "Web Buttons"

    This will start out as a URL like this:

        http://192.168.68.64:8000/tablet

2. Open the "Configure" gear on the top right and select..

    | | |
    |---|---|
    | Pages | 6 (or the page number chosen to import the buttons) |
    | Columns | 3 |
    | Show page headings | uncheck |
    | Hide fullscreen button | check |
    | Hide configuration button | check |

    "Close" the configuration button.

    The final URL will look similar to this:

        http://192.168.68.64:8000/tablet?cols=3&noconfigure=1&nofullscreen=1&pages=6
   
3. Save the URL

Recommend saving that URL and giving it to the presenter.

Perhaps send the URL in an email that can be opened on a phone.  Then bookmark the URL to the home screen.  Some phones then allow one to transfer a bookmark to other phones.

### Assumptions
1) BitFocus Companion v3 software is installed.
2) On the Companion launch screen the computer's IP address is selected.  (Not selected: Localhost 127.0.0.1)
3) The IP addresses on the computers running ProPresenter and Companion are static.  (The addresses do not change.)
 
## Change Log
### V 2.0.0
- Easier to configure Companion by importing button page and triggers.
- Rewritten to run on Companion v3.x.x
- Removed dependency of Companion running on Windows by removing the PowerShell script.
- Removed dependencies on having a ProPresenter connection in Companion.