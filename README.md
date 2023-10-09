# Fax_Back_PowerShell_Script
## Overview
This is a Fax Back Powershell integration with Zetafax Server. This script allows you to automatically fax back senders that send to a specified fax number within a specified Zetafax user inbox.

## Use Case
Discontinuing fax lines: If you will be discontinuing a fax line and want to notify the senders sending to this fax line, this would be an effective method alongside formal/traditional communication as well (like email, phone call, etc). 

## Prerequisites:
To implement within your network, this script assumes the following: 
1. Zetafax Server installed in your environment.
2. Zetafax Server configured for Z-Submit processing.
3. Microsoft Task Scheduler to run this script on a scheduled-basis. Run at least once per hour.

*However*, if you pull this repository from Github and store the files locally, you can use relative paths to test. For more information, see video demonstration towards the end of the README file. 

## How to use
Modify all variables under the "REQUIRED" section of the PowerShell script (shown below).   
![image](https://github.com/acmignona/Fax_Back_Script/assets/81653524/7b42881a-4027-4461-99da-ca388bf2068e)

## Logical Diagram: 
![Diagram](https://github.com/acmignona/Fax_Back_Script/assets/81653524/58a35df5-93e4-4b63-a48a-20ae495c1bdd)

## Video Demonstration:
[![Watch the video](https://img.youtube.com/vi/XGCBd7Fdv28/0.jpg)](https://youtu.be/XGCBd7Fdv28)


