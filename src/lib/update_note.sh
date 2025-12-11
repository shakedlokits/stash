update_note() {
	local note_id="$1"
	local html_content="$2"
	
	result=$(osascript 2>&1 <<EOF
tell application "Notes"
  try
    set deletedNotesFolder to folder "Recently Deleted"
    set theNote to first note whose id is "$note_id"
    set theFolder to container of theNote
    
    if theFolder is equal to deletedNotesFolder then
      error "Note is in Recently Deleted"
    end if
    
    set body of theNote to "$html_content"
    return "$note_id"
  on error errMsg
    error errMsg
  end try
end tell
EOF
)
	
	# Check if result matches the note_id we tried to update
	if [ "$result" = "$note_id" ]; then
		echo "$result"
		return 0
	else
		echo "Error: Failed to update note $note_id: $result" >&2
		return 1
	fi
}
