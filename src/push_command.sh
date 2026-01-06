# Read markdown content from file
file_path="${args[file]}"
folder_name="${args[--folder]:-}"

if [ ! -f "$file_path" ]; then
	echo "Error: File not found: $file_path" >&2
	exit 1
fi

echo "Reading file: $file_path"
markdown_content=$(read_markdown_file "$file_path")

# Extract ID from frontmatter (may not exist)
note_id=$(get_id_from_frontmatter "$markdown_content") || true

# Check if note exists in Apple Notes
note_found=""
if [ -n "$note_id" ]; then
	echo "Searching for note..."
	note_found=$(find_note "$note_id") || true
fi

# If note not found, prompt user to create new
if [ -z "$note_found" ]; then
	echo "Note not found in Apple Notes."
	echo "Create new note? (y/n)"
	read -r response
	
	if [[ ! "$response" =~ ^[Yy]$ ]]; then
		echo "Operation cancelled"
		exit 0
	fi
	
	# Strip frontmatter and convert to HTML
	echo "Creating note..."
	html_content=$(echo "$markdown_content" | strip_frontmatter | markdown_to_html)

	# Create new note (optionally in specified folder)
	new_note_id=$(create_note "$html_content" "$folder_name")
	if [ -z "$new_note_id" ]; then
		echo "Error: Failed to create note" >&2
		exit 1
	fi
	
	# Update frontmatter with new ID
	updated_content=$(update_frontmatter "$markdown_content" "$new_note_id")
	write_markdown_file "$file_path" "$updated_content"
	
	echo "Note created: $new_note_id"
else
	# Note exists, update it
	echo "Updating note..."
	html_content=$(echo "$markdown_content" | strip_frontmatter | markdown_to_html)
	
	if ! update_note "$note_found" "$html_content"; then
		echo "Error: Failed to update note" >&2
		exit 1
	fi
	
	echo "Note updated: $note_found"
fi
