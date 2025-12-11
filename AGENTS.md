# Agent Development Guidelines

This document outlines the coding guidelines, development philosophy, and project structure established for the Apple Notes Sync Tool. These guidelines should be followed by any AI agent or developer working on this project.

## Philosophy

We follow the **Zen of Python** as our guiding principle:

- **Beautiful is better than ugly**
- **Explicit is better than implicit**
- **Simple is better than complex**
- **Complex is better than complicated**
- **Flat is better than nested**
- **Sparse is better than dense**
- **Readability counts**
- **Special cases aren't special enough to break the rules**
- **Although practicality beats purity**
- **Errors should never pass silently**
- **Unless explicitly silenced**
- **In the face of ambiguity, refuse the temptation to guess**
- **There should be one-- and preferably only one --obvious way to do it**
- **Now is better than never**
- **Although never is often better than *right* now**
- **If the implementation is hard to explain, it's a bad idea**
- **If the implementation is easy to explain, it may be a good idea**

## Core Principles

### Simplicity
- Keep it simple. Don't over-engineer.
- Avoid premature optimization.
- Prefer one-line solutions when they're clearer (e.g., `pcregrep` over 40 lines of bash).
- Don't add features or complexity until they're needed.

### Explicitness
- Be explicit in naming, behavior, and user interactions.
- Use `read` commands for user prompts with clear messaging.
- Log before long-running operations (e.g., "Searching for note...").
- Error messages should be clear and actionable.

### Purity
- Utility functions should be pure: input → output, no side effects.
- Functions that perform I/O (file system, AppleScript) are integration functions.
- Separate concerns: parsing logic vs. I/O operations.

## Project Structure

### Directory Layout

```
src/
  lib/              # Pure and integration functions
  bashly.yml        # CLI configuration
  *_command.sh      # Command implementations

test/
  cases/                   # All test specs
    unit_*_spec.sh         # Unit tests (pure functions)
    integration_*_spec.sh  # Integration tests (I/O, AppleScript)
    e2e_*_spec.sh          # End-to-end tests (full CLI workflows)
  fixtures/                # Test fixture files (flat structure)
  approvals/               # Auto-generated approval files
  approvals.bash           # Approval testing framework
  approve                  # Test runner

dist/                # Generated CLI (from bashly)
```

### Naming Conventions

- **Utility functions**: `function_name.sh` (e.g., `strip_frontmatter.sh`)
- **Test specs**: `{type}_{function_name}_spec.sh` (e.g., `unit_strip_frontmatter_spec.sh`)
- **Approval files**: Custom names describing the test (e.g., `strip_frontmatter_with_apple_id`)

## Testing Approach

### Test Categories

1. **Unit Tests** (`unit_*_spec.sh`)
   - Test pure functions only
   - No I/O operations
   - No external dependencies (except standard tools like `pcregrep`)
   - Fast execution
   - Examples: `strip_frontmatter`, `get_id_from_frontmatter`, `update_frontmatter`

2. **Integration Tests** (`integration_*_spec.sh`)
   - Test I/O operations and external integrations
   - File system operations: read, write
   - AppleScript operations: create, read, update, delete notes
   - Require actual Apple Notes application
   - Include cleanup (create → test → delete)
   - Add WARNING comments at the top of the file

3. **E2E Tests** (`e2e_*_spec.sh`)
   - Test full CLI workflows
   - Mock integration functions by redefining them (not aliases)
   - Simulate bashly args with `declare -A args`
   - Test user interaction flows
   - **Must unset mocks after each test** to avoid pollution
   - Run with `SKIP_INTEGRATION=1` to skip integration tests
   - Examples: `push` command, `pull` command

### Approval Testing

We use `approvals.bash` for snapshot testing:

```bash
# Source approvals.bash and the function being tested
source approvals.bash
source "$LIB_PATH/strip_frontmatter.sh"

describe "strip_frontmatter"
  
  # Use custom approval file names for readability
  approve "cat $FIXTURES_PATH/with_apple_id.md | strip_frontmatter" \
    "strip_frontmatter_with_apple_id"
```

**Approval file naming**: Use descriptive names that indicate what's being tested:
- `strip_frontmatter_with_apple_id`
- `strip_frontmatter_no_frontmatter`
- `root_command_help`

**Environment variables** for clean paths:
- `$FIXTURES_PATH` - Path to test fixtures
- `$LIB_PATH` - Path to lib functions  
- `$CLI_PATH` - Path to CLI executable
- `$APPROVALS_BASH` - Path to approvals.bash (for portable sourcing)

### Test Execution

```bash
make test           # Run all tests (unit + integration + e2e)
make test-unit      # Run only unit tests (skips integration)
```

Environment variable:
- `SKIP_INTEGRATION=1` - Skip integration tests (useful for CI)

### Integration Test Pattern

```bash
#!/usr/bin/env bash

# WARNING: This test creates and deletes actual Apple Notes
# Make sure you're running in a test environment

source approvals.bash

describe "create_note"
  
  # Create, test, cleanup
  note_id=$(create_note "Test content")
  approve "echo '$note_id'" "create_note_with_content"
  delete_note "$note_id"
```

**Key points**:
- Always clean up after yourself (create → test → delete)
- Use `allow_diff` for dynamic IDs: `allow_diff "x-coredata://[^/]+/ICNote/p[0-9]+"`
- Keep it simple: don't over-engineer setup/teardown

### E2E Test Pattern

**CRITICAL**: The `approve` function runs commands via `eval` in a subshell. Mocks defined in the parent shell will NOT be visible. You MUST define mocks INSIDE the approve string.

```bash
#!/usr/bin/env bash

source "$APPROVALS_BASH"

# Source all lib functions (for pure utilities only)
for f in "$LIB_PATH"/*.sh; do source "$f"; done

SRC_PATH="$PWD/../src"

describe "push_command"

  # Setup: create temp file
  test_file=$(mktemp)
  echo "# Test" > "$test_file"
  
  # CORRECT: Define mocks INSIDE the approve string
  approve "
    find_note() { return 1; }
    create_note() { echo 'x-coredata://test/ICNote/p123'; return 0; }
    export -f find_note create_note
    declare -A args; args[file]='$test_file'
    echo 'y' | source $SRC_PATH/push_command.sh
    unset -f find_note create_note
  " "push_new_file_confirm"
  
  # Cleanup temp file
  rm -f "$test_file"
```

**Key points**:
- **MOCKS MUST BE INSIDE THE APPROVE STRING** - parent shell functions are NOT visible in eval subshell
- Use `export -f function_name` after defining mocks
- Use `declare -A args; args[key]='value'` to simulate bashly arguments
- Use `echo 'y' |` to simulate user input for prompts
- Use `allow_diff` before `approve` to normalize dynamic paths (e.g., temp files)
- Clean up temp files after each test

## Code Style

### Shell Script Conventions

- Use tabs for indentation (bashly default)
- Use `local` for function variables
- Quote variables: `"$variable"` not `$variable`
- Check command success: `if ! command; then ... fi`
- Use `set -e` in test scripts

### Function Design

**Pure functions**:
```bash
strip_frontmatter() {
	cat | pcregrep -M -v '^---\s*([\s\S]*?)\s*^---\n?'
}
```

**Integration functions**:
```bash
create_note() {
	local content="$1"
	
	result=$(osascript <<EOF
tell application "Notes"
  try
    set newNote to make new note with properties {body:"$content"}
    return id of newNote
  on error
    return ""
  end try
end tell
EOF
)
	
	echo "$result"
}
```

### Error Handling

- Return empty string or error code on failure
- Log errors to stderr: `echo "Error: message" >&2`
- Exit with non-zero code on fatal errors: `exit 1`
- Use existing error message format from codebase (see `push_command.sh`)

### User Interaction

```bash
# Explicit prompts
echo "Create new note? (y/n)"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Operation cancelled"
  exit 0
fi

# Progress messages
echo "Searching for note..."
echo "Creating note..."
echo "Note created successfully"
```

## Development Workflow

### Incremental Development

Implement **one function at a time** with tests:

1. Implement function
2. Write test spec
3. Run tests with `AUTO_APPROVE=1`
4. Verify approval files
5. Run tests normally
6. **Wait for approval before proceeding to next function**

### Gate System

Each implementation gate includes:
- Function implementation
- Test spec file
- Approval files
- Documentation updates (if needed)
- Verification that all tests pass

**Do not proceed to the next gate without explicit approval.**

## Design Decisions

### Frontmatter Handling

- Use `apple_notes_id` field (not `id`)
- Strip frontmatter before pushing to Apple Notes
- Preserve frontmatter when pulling from Apple Notes
- Update or create frontmatter as needed

### Apple Notes Integration

- Use AppleScript for all Apple Notes operations
- Store Apple Notes ID in frontmatter (format: `x-coredata://...`)
- No blockquotes or markers in note body
- Let Apple Notes handle note titles (don't set explicitly)

### Content Format

- Use **Pandoc** for markdown↔HTML conversion
- `markdown_to_html`: `pandoc -f gfm -t html --wrap=none`
- `html_to_markdown`: `pandoc -f html -t gfm-raw_html --wrap=none` (with post-processing)
- Strip frontmatter before pushing to Apple Notes
- Preserve frontmatter when pulling from Apple Notes

### Apple Notes HTML Quirks

Apple Notes has specific HTML behaviors that require special handling:

1. **H1 to styled text**: Apple Notes converts `<h1>` tags to `<div><b><span style="font-size: 24px">...</span></b></div>`. We convert this back to `<h1>` before pandoc processing.
2. **Div wrappers**: Apple Notes wraps content in `<div>` tags. Using `gfm-raw_html` instead of `gfm` prevents these from being passed through as raw HTML.
3. **List separators**: Pandoc outputs `&nbsp;` between consecutive lists. We remove these with sed.
4. **Trailing whitespace**: Apple Notes' `<div><br></div>` elements leave whitespace-only lines. We trim these.
5. **Quote escaping**: HTML content with double quotes must be escaped (`\"`) before passing to AppleScript.

### Error Recovery

- If note not found by ID: prompt user to create new
- Always ask for confirmation before destructive operations
- Make behavior explicit to the user

## Makefile Targets

```makefile
build:          # Generate CLI from bashly
test:           # Run all tests
test-unit:      # Run unit tests only (skip integration)
```

## Documentation

- Keep README.md updated with user-facing documentation
- Keep AGENTS.md updated with development guidelines
- Use clear commit messages
- Add comments for complex logic only (prefer self-documenting code)

## Common Pitfalls to Avoid

1. **Don't over-engineer**: Resist adding features "just in case"
2. **Don't batch approvals**: Mark todos complete immediately, not in batches
3. **Don't mix concerns**: Keep pure functions pure
4. **Don't forget cleanup**: Always delete test notes in integration tests
5. **Don't use fancy formatting**: Keep error messages simple and clear
6. **Don't advance without approval**: Wait for explicit go-ahead between gates

## Tools and Dependencies

- **Bashly**: CLI framework (via Docker)
- **approvals.bash**: Approval testing framework
- **pcregrep**: PCRE regex tool (for frontmatter stripping)
- **osascript**: AppleScript execution (for Apple Notes integration)
- **Pandoc**: Markdown↔HTML conversion (`pandoc -f gfm -t html --wrap=none`)

## Current Implementation Status

### Completed Gates (10 of 10)

| Gate | Component | Description | Status |
|------|-----------|-------------|--------|
| 1 | `strip_frontmatter.sh` | Strip YAML frontmatter using pcregrep | ✅ |
| 2 | `get_id_from_frontmatter.sh` | Extract apple_notes_id from frontmatter | ✅ |
| 3 | `update_frontmatter.sh` | Add/update apple_notes_id in frontmatter | ✅ |
| 4 | `create_note.sh`, `delete_note.sh` | Create/delete Apple Notes via AppleScript | ✅ |
| 5 | `find_note.sh` | Find note by ID (filters Recently Deleted) | ✅ |
| 5.5 | `markdown_to_html.sh`, `html_to_markdown.sh` | Pandoc-based conversion | ✅ |
| 6 | `read_note.sh` | Read note body content by ID | ✅ |
| 7 | `update_note.sh` | Update note content by ID | ✅ |
| 7.5 | `read_markdown_file.sh`, `write_markdown_file.sh` | File I/O utilities | ✅ |
| 8 | Test reorganization | Moved tests to `test/cases/` | ✅ |
| 9 | `push_command.sh` | Push markdown file to Apple Notes | ✅ |
| 10 | `pull_command.sh` | Pull note from Apple Notes to markdown | ✅ |

### Test Coverage

- **Unit tests**: 36 tests (pure functions)
- **Integration tests**: 11 tests (Apple Notes operations)
- **E2E tests**: 15 tests (CLI workflows)
- **Total**: 62 tests

## Questions?

When in doubt:
- Keep it simple
- Make it explicit
- Follow existing patterns in the codebase
- Ask for clarification rather than guessing
