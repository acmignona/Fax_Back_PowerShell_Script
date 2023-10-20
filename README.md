# Fax_Back_PowerShell_Script
## Overview
This is a Powershell integration with Zetafax Server that enables you to automatically fax back senders that send to a specified fax number within a specified Zetafax user inbox.

## Logical Diagram:
*Please click diagram to enlarge* 
![Diagram](https://github.com/acmignona/Fax_Back_PowerShell_Script/assets/81653524/dbc58ce9-504a-4b2c-80f4-8a9a72a1fdcb)

### Example Use Case
Discontinuing fax lines: If you will be discontinuing a fax line and want to notify the senders sending to this fax line, this would be an effective method alongside formal/traditional communication as well (like email, phone call, etc). 

## Prerequisites:
To implement within your network, this script assumes the following: 
1. [Zetafax Server]([url](https://www.equisys.com/Products/Zetafax)) installed in your environment.
2. Zetafax Server configured for [Z-Submit ]([url](https://www.equisys.com/Support/technotes/howto-using-zsubmit)) processing, this can be configured within [Zetafax Configuration]([url](https://www.equisys.com/support/help_and_resource/zetafax/help/setup/zetafax_configuration.htm)).
3. Microsoft Task Scheduler to run this script on a scheduled-basis. Run at least once per hour.

*However*, if you pull this repository from Github and store the files locally, you can use relative paths to test. For more information, see video demonstration towards the end of the README file. 

## How to use

1. Create a custom document to faxback to your senders. Example can be found in the [/files ]([url](https://github.com/acmignona/Fax_Back_PowerShell_Script/tree/main/files)) folder.
2. Modify all variables under the "REQUIRED" section of the PowerShell script (shown below).   
![required](https://github.com/acmignona/Fax_Back_PowerShell_Script/assets/81653524/b6b65578-1139-4ec3-9bb9-8d4002fe6477)




## Video Demonstration:
*Please click the below image to be redirected to YouTube.*

[![Watch the video](https://img.youtube.com/vi/KxXgptCCjqg/0.jpg)](https://youtu.be/KxXgptCCjqg?si=Jz9P3YCGFYp0U2u_)

