;	Friday, August 18, 2023
;	Michael Sokoliuk Jr
;	Thanks to Alex Glib for help with loop function
;	xCopy Pre-Release version 0.9
;
;	Function on script execute:
;	Copy selected file(s) data to clipboard
;	Copy file(s) to /Old folder in current file directory
;	Append LastModifiedDate to file(s)
;	If file(s) exist, do nothing
;	Format: %filename% (%date-last-modified%)
;	Ex:	"Scheduled May report (2023-8-18).doc"
;		"Presentation for Client (2023-8-18).pptx"
;		"Tank manifold layout 2023-8-18).dwg"

#Persistent	; Will keep script running until told to exit.

; RUN SCRIPT
; {Ctrl}{Alt}{x}
^!x::

; CLIPBOARD
clipboard = ; Start off empty to allow ClipWait to detect when the text has arrived.
Send ^c 
ClipWait 

; Split the clipboard variable into separate file names, they are delimited by a carriage return
file_name_array := StrSplit( clipboard,"`r`n")

; Loop through the filename array		
Loop % file_name_array.MaxIndex()
{
	CurrentFile := file_name_array[A_Index]

	; TIMESTAMP
	FileGetTime, ModifiedDate, %clipboard%, M
	; Get time info from file, [write to new variable], [path is clipboard variable], [Modified date]
	; ! Modify "(xxxx-X-x)" for timestamp formating
	FormatTime, ModifiedDate, %ModifiedDate%, (yyyy-M-d)
	; FormatTime, [write to new variable], [take from old variable], [time format]

	SplitPath, CurrentFile, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	; Break up file info, [take from clipboard variable], ~[explanatory]~

	; DIRECTORIES
	dest_dir=%OutDir%\Old
	; [variable: Destination directory] = [OutDrive info from SplitPath] [Write to subdirectory "/old"]
	IfNotExist, %dest_dir%
	FileCreateDir, %dest_dir%
	; Check whether destination directory exists, if not then create new

	; FILECOPY
	FileCopy, %CurrentFile%, %dest_dir%\%OutNameNoExt%%a_space%%ModifiedDate%.%OutExtension%, 1
	; Copy file, [clipboard variable], [destination directory + "\" + Filename_noExtension + Blank literal space + variable: modified time + "." dot character + file extension]

}

; TOOLTIP - DONE
if ErrorLevel
	tooltip, Copy failed for %ErrorLevel% file(s)
else
	tooltip, File copied successfully
settimer, hide_tip, 1000
return
hide_tip:	; just a nice method to hide the tip
	tooltip,
return
