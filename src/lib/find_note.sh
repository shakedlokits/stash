find_note() {
	local note_id="$1"
	
	result=$(osascript 2>&1 <<EOF
tell application "Notes"
  try
    set deletedNotesFolder to folder "Recently Deleted"
    set theNote to first note whose id is "$note_id"
    set theFolder to container of theNote
    
    if theFolder is equal to deletedNotesFolder then
      return ""
    end if
    
    return id of theNote
  on error
    return ""
  end try
end tell
EOF
)
	
	if [ -z "$result" ]; then
		return 1
	else
		echo "$result"
		return 0
	fi
}
