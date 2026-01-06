create_note() {
	local content="$1"
	local folder_name="${2:-}"

	# Escape double quotes for AppleScript string
	local escaped_content="${content//\"/\\\"}"

	if [ -n "$folder_name" ]; then
		# Create note in specified folder
		result=$(osascript 2>&1 <<EOF
tell application "Notes"
  try
    -- Find or create folder
    set targetFolder to missing value
    repeat with f in folders
      if name of f is "$folder_name" then
        set targetFolder to f
        exit repeat
      end if
    end repeat

    if targetFolder is missing value then
      set targetFolder to make new folder with properties {name:"$folder_name"}
    end if

    -- Create note in folder
    set newNote to make new note at targetFolder with properties {body:"$escaped_content"}
    return id of newNote
  on error errMsg
    error errMsg
  end try
end tell
EOF
)
	else
		# Create note in default location
		result=$(osascript 2>&1 <<EOF
tell application "Notes"
  try
    set newNote to make new note with properties {body:"$escaped_content"}
    return id of newNote
  on error errMsg
    error errMsg
  end try
end tell
EOF
)
	fi

	# Check if result looks like a valid note ID
	if [[ "$result" =~ ^x-coredata:// ]]; then
		echo "$result"
		return 0
	else
		echo "Error: Failed to create note: $result" >&2
		return 1
	fi
}
