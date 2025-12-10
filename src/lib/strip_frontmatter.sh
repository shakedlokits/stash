strip_frontmatter() {
	cat | pcregrep -M -v '^---\s*([\s\S]*?)\s*^---\n?'
}
