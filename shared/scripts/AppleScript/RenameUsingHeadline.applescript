on run
	-- get the list of selected ID's in front window
	set selectedItems to GetSelection()

	-- show about
	AboutScript()

	-- process each item
	set theCount to 0
	tell application "iView MediaPro"
		repeat with theItem in selectedItems
			-- get exif date & original name
			set newName to ""
			set theName to the name of theItem
			set thePath to the path of theItem
			--display dialog thePath
			set theHeadline to the headline of theItem

			-- form new name by stripping all punctuation from the headline and
			-- replace all spaces with underscores
			set newName to my tidyString(theHeadline)

			-- set newName to theHeadline

			-- if the old name has an extension, append it to new name
			-- But change it to lower case
			set nc to the number of characters in theName
			if character (nc - 3) of theName = "." then
				set thefileextension to my change_case((get text (nc - 3) through nc of theName), 0)
			end if

			-- rename
			if theName � (newName & thefileextension) then

				--does a file already exist with this name?
				tell application "Finder"
					set filefolder to (folder of alias thePath)
					set filenumber to ""
					set counter to 1
					set myloop to true
					repeat until myloop is false
						if exists file (newName & filenumber & thefileextension) of filefolder then
							if filenumber = "" then
								set filenumber to "_" & counter
							else
								set filenumber to "_" & counter + 1
								set counter to counter + 1
							end if
						else
							set myloop to false
						end if
					end repeat
				end tell
				set the name of theItem to (newName & filenumber & thefileextension)
				if the name of theItem = (newName & filenumber & thefileextension) then set theCount to theCount + 1
			end if
			--end try
		end repeat
	end tell

	ShowResult(theCount)
end run


-- get the selected media items in an array ---------------------------------------------
on GetSelection()
	set selectedItems to {}
	tell application "iView MediaPro"
		if catalog 1 exists then set selectedItems to the selection of catalog 1
	end tell
	if number of items in selectedItems is 0 then
		display dialog �
			"You need to select at least one media item in the front catalog in order to use this script." buttons {"OK"} default button �
			"OK" with icon 1 giving up after 10
		error number -128
	end if
	return selectedItems
end GetSelection

-- Strip punctuation and replace spaces with underscore ------------
on tidyString(the_string)
	set the_delims to {"!", "@", "�", "#", "�", "$", "%", "^", "&", "*", "(", ")", "=", "+", "[", "]", "{", "}", ";", ":", "\"", "'", "\\", "|", ",", "<", ".", ">", "/", "?", "`", "~", "_"}
	-- store the originals and set up the marker.
	set {OLD_delim, _marker_} to {AppleScript's text item delimiters, "�"}
	-- process each of the delimiters in the_delims replacing each with the  _marker_
	repeat with this_delim in the_delims
		my atid(this_delim) -- see the handler that follows
		set the_string to text items of the_string
		my atid(_marker_)
		set the_string to text items of the_string as string
	end repeat
	my atid(_marker_)
	set the_string to text items of the_string
	my atid(OLD_delim)
	set the_string to the_string as string
	-- now replace spaces with "_"
	set the_words to words of the_string
	my atid("_")
	set the_string to the_words as string
	my atid("")
	return the_string
end tidyString

on atid(the_delim)
	set AppleScript's text item delimiters to the_delim
end atid

on replaceSpaces(the_text)
	set myWords to words of the_text
	my atid("_")
	set the_text to myWords as string
	my atid("")
	return the_text
end replaceSpaces

-- about this script ---------------------------------------------

on AboutScript()
	display dialog �
		"This script will rename original files of all selected items using valid values in the \"Headline\" field.

Resulting filenames will have all punctuation removed, and spaces replaced with \"_\".

It will also change the file extension, if present, to lowercase." buttons {"Cancel", "Rename"} default button 2 with icon 1

	set theAnswer to the button returned of the result
	return theAnswer
end AboutScript


-- show result ---------------------------------------------

on ShowResult(theCount)
	if theCount = 0 then
		set theMsg to "Script completed." & return & "No items were renamed."
	else if theCount = 1 then
		set theMsg to "Script completed." & return & "1 item was renamed."
	else
		set theMsg to "Script completed." & return & theCount & " items were renamed."
	end if
	display dialog theMsg buttons {"OK"} default button "OK" with icon 1 giving up after 10
end ShowResult

-- Change case --------------------------------------
-- Taken from https://www.apple.com/applescript/guidebook/sbrt/pgs/sbrt.07.htm

on change_case(this_text, this_case)
	if this_case is 0 then
		set the comparison_string to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		set the source_string to "abcdefghijklmnopqrstuvwxyz"
	else
		set the comparison_string to "abcdefghijklmnopqrstuvwxyz"
		set the source_string to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	end if
	set the new_text to ""
	repeat with this_char in this_text
		set x to the offset of this_char in the comparison_string
		if x is not 0 then
			set the new_text to �
				(the new_text & character x of the source_string) as string
		else
			set the new_text to (the new_text & this_char) as string
		end if
	end repeat
	return the new_text
end change_case