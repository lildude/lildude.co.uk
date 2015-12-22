-- This script will clear out the description field of all selected photos that have the
-- "Description" field set to "AppleMark" following an import from iPhoto
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
			set theDesc to the caption of theItem
			--return theDesc
			if the theDesc is "AppleMark
" then
				set the caption of theItem to ""
				if the caption of theItem = "" then set theCount to theCount + 1
			end if
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
		display dialog Â
			"You need to select at least one media item in the front catalog in order to use this script." buttons {"OK"} default button Â
			"OK" with icon 1 giving up after 10
		error number -128
	end if
	return selectedItems
end GetSelection


-- about this script ---------------------------------------------

on AboutScript()
	display dialog Â
		"This script will remove any \"Description\" that is set to \"AppleMark\" following an import from iPhoto." buttons {"Cancel", "Remove"} default button 2 with icon 1
	
	set theAnswer to the button returned of the result
	return theAnswer
end AboutScript


-- show result ---------------------------------------------

on ShowResult(theCount)
	if theCount = 0 then
		set theMsg to "Script completed." & return & "No descriptions we removed."
	else if theCount = 1 then
		set theMsg to "Script completed." & return & "1 description was removed."
	else
		set theMsg to "Script completed." & return & theCount & " descriptions were removed."
	end if
	display dialog theMsg buttons {"OK"} default button "OK" with icon 1 giving up after 10
end ShowResult