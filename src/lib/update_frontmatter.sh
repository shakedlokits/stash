update_frontmatter() {
	local content="$1"
	local apple_notes_id="$2"
	
	echo "---"
	printf "$(echo "$content" | pcregrep -M -o1 '^---\s*([\s\S]*?)\s*^---\n?' | grep -v 'apple_notes_id')\n" | grep .
	echo "apple_notes_id: $apple_notes_id"
	echo "---\n"
	echo "$(echo "$content")" | pcregrep -M -v '^---\s*([\s\S]*?)\s*^---\n?'
}
