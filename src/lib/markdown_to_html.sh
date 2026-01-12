# Helper: Wrap headings in Apple Notes' native format
# Apple Notes expects: <div><b><hX>...</hX></b></div>
_wrap_headings_for_apple_notes() {
	sed -e 's/<h1>\(.*\)<\/h1>/<div><b><h1>\1<\/h1><\/b><\/div>/' \
	    -e 's/<h2>\(.*\)<\/h2>/<div><b><h2>\1<\/h2><\/b><\/div>/' \
	    -e 's/<h3>\(.*\)<\/h3>/<div><b><h3>\1<\/h3><\/b><\/div>/'
}

markdown_to_html() {
	cat | pandoc -f gfm -t html --wrap=none | _wrap_headings_for_apple_notes || {
		echo "Error: Failed to convert markdown to HTML" >&2
		return 1
	}
}
