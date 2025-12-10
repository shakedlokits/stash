create_note() {
	local content="$1"
	
	result=$(osascript 2>&1 <<EOF
tell application "Notes"
  try
    set newNote to make new note with properties {body:"$content"}
    return id of newNote
  on error errMsg
    error errMsg
  end try
end tell
EOF
)
	
	# Check if result looks like a valid note ID
	if [[ "$result" =~ ^x-coredata:// ]]; then
		echo "$result"
		return 0
	else
		echo "Error: Failed to create note: $result" >&2
		return 1
	fi
}
