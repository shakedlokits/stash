# Helper: Convert Apple Notes heading patterns to proper HTML headings
# Apple Notes uses font-size styles for headings:
#   - Title (29px, bold) → H1
#   - Heading (22px, bold) → H2
#   - Subheading (16px, bold) → H3
# Note: Normal text is also 16px but without the <b> wrapper
_convert_apple_headings() {
	sed -e 's/<div><b><span style="font-size: 29px">\(.*\)<\/span><\/b><\/div>/<h1>\1<\/h1>/' \
	    -e 's/<div><b><span style="font-size: 22px">\(.*\)<\/span><\/b><\/div>/<h2>\1<\/h2>/' \
	    -e 's/<div><b><span style="font-size: 16px">\(.*\)<\/span><\/b><\/div>/<h3>\1<\/h3>/'
}

# Helper: Remove nbsp list separators
_remove_nbsp() {
	sed 's/^&nbsp;$//'
}

# Helper: Trim trailing whitespace
_trim_trailing_whitespace() {
	sed 's/[[:space:]]*$//'
}

html_to_markdown() {
	cat | _convert_apple_headings | pandoc -f html -t gfm-raw_html --wrap=none | _remove_nbsp | _trim_trailing_whitespace | cat -s || {
		echo "Error: Failed to convert HTML to markdown" >&2
		return 1
	}
}
