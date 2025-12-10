get_id_from_frontmatter() {
	local content="$1"

	# Extract frontmatter and parse id field
	id=$(echo "$content" | sed -n '/^---$/,/^---$/p' | sed '1d;$d' | pcregrep -o1 '^apple\_notes\_id\:\s*([a-z\-]+)\s*$')

	# Verify id was found and return accordingly
	if [ -z "$id" ]; then
		return 1
	else
		echo "$id"
		return 0
	fi
}
