markdown_to_html() {
	cat | pandoc -f gfm -t html --wrap=none || {
		echo "Error: Failed to convert markdown to HTML" >&2
		return 1
	}
}
