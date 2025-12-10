html_to_markdown() {
	cat | pandoc -f html -t gfm --wrap=none || {
		echo "Error: Failed to convert HTML to markdown" >&2
		return 1
	}
}
