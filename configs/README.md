# Configuration CSV descriptions below

## faxlines.csv
Each bullet point below represents a field (or column) from the csv: 
- ServerName: What is the hostname of the Zetafax server?
- z_fax_user: What is the receiving Zetafax username?
- z_in_path: The path will likely be `\\<SERVERNAME>\zfax\<USER>\z-in`
- Trigger_Number: If we detect this number in the CTL files, we will fax back the originator
- fax_back_document: Enter path of the document you'd like to fax back.
- sub_file: Enter the path of the corresponding .sub file that this script will use as a template.
- z_submit: Enter the complete UNC to your Z-Submit directory. Dont not leave any unnecessary white space or returns. If unsure, check in Zetafax Configuration. 
		
## log_paths.csv:
Enter all paths to the log files. Some of these are only for logging purposes, but others are critical for processing. These files can start off as blank.  

## substitutes.csv
Enter any susbsitutes. There are two different methods of substiutions: 
1. CLI
   -  Required fields: CLI, Substitute_CLI, & Substitute_Method
   -  Enter "CLI" for Substitute_Method field. 
2. Both (CLI & CSID).
   -  Required fields: CLI, CSID, Substitute_CLI, Substitute_Method
   -  Enter "CLI_and_CSID" for Substitute_Method field.
