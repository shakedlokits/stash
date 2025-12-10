delete_note() {
	local note_id="$1"
	
	result=$(osascript 2>&1 <<EOF
tell application "Notes"
  try
    set theNote to first note whose id is "$note_id"
    delete theNote
    return "$note_id"
  on error errMsg
    error errMsg
  end try
end tell
EOF
)
	
	# Check if result matches the note_id we tried to delete
	if [ "$result" = "$note_id" ]; then
		echo "$result"
		return 0
	else
		echo "Error: Failed to delete note $note_id: $result" >&2
		return 1
	fi
}
