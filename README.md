```
                                     
                                     
  ▄█████ ██████ ▄████▄ ▄█████ ██  ██ 
  ▀▀▀▄▄▄   ██   ██▄▄██ ▀▀▀▄▄▄ ██████ 
  █████▀   ██   ██  ██ █████▀ ██  ██ 
                                     
                                     
```

Bidirectionally sync Markdown files with Apple Notes!

## Getting Started

### Installation

```bash
brew tap shakedlokits/stash
brew install stash
```

### Quick Example

Push a markdown file to Apple Notes:
```bash
stash push my-note.md
```

Pull changes back from Apple Notes:
```bash
stash pull my-note.md
```

That's it! The tool uses front-matter to track which Apple Note corresponds to your file.

## Background & Rationale

Apple Notes has been my daily driver for years. I love its simplicity—it syncs fast, stays out of the way, and just lets me write.

I've explored the full spectrum of note-taking apps: `Workflowy`, `Obsidian`, `Bear`, `Evernote`, `Notion`, `Google Keep`, `GoodNotes`, and others I've since forgotten. Each promised to revolutionize how I capture thoughts. But eventually, I realized something simple: note-taking is about writing things down, not managing a complex system. I came back to Apple Notes and haven't looked back.

There's just one friction point. When I'm building things—which is most days—I live in Markdown. At work, I sync those files to Notion or Confluence with CLI tools. For personal projects, everything goes into Git. But increasingly, I find myself writing quick notes that don't belong to any project—just ideas, experiments, small discoveries—and I want them on Apple Notes where I can read them anywhere. Right now, there's no clean path from my Markdown workflow to my notes.

I went searching for CLI tools to bridge this gap. What I found was disappointing: tools either pack in too many features, making them brittle and hard to maintain, or they offer so little functionality (read-only sync) that they're effectively useless.

So I built my own.

The requirements are straightforward:
- Run from the shell without configuration files
- Use AppleScript for maximum compatibility and stability
- Bidirectionally sync Markdown and Apple Notes, using front-matter to track state

## How It Works

### Pushing Notes

Congratulations! You've written a new Markdown note, it's nice and tidy, and you've even run `vale` on it. Now all that remains is getting it into Apple Notes. Here's what you need to do:

1. Run `push my-cool-note.md`.
2. A new note will be created:
   ```
   My Cool Note
   ...
   ```
3. Front-matter with a unique identifier will be added to your markdown file:
   ```md
   ---
   apple_notes_id: my-new-cool-note-identifier 
   ---

   # My Cool Note
   ...
   ```
   > NOTE: If you already have front-matter, it will be added to the existing front-matter.

Made changes to the Markdown file and now it's out of sync? Simply:
1. Rerun `push my-cool-note.md`.
2. The tool searches for the note matching your identifier (`id_my-new-cool-note-identifier`).
3. It rewrites the note's content with your updated Markdown.
   > NOTE: If no note was found (due to unexpected ID changes) you will be asked if you'd like to create a new note, which will overwrite your previous ID.

### Pulling Notes

You've gone off for your coffee/potty/meeting break, and while skimming through your note on your phone, you realized you made a terrible mistake—which inevitably led you to rewrite half of it.

Now the panic has settled, you're back at your computer, and you're wondering: "What the hell have I done, and how can I possibly get all those changes back into my Markdown?"

Don't fret. Simply:
1. Run `pull my-cool-note.md`.
2. The tool searches for the note matching your identifier (`id_my-new-cool-note-identifier`).
3. It rewrites your local Markdown file with the content from Apple Notes.
   > NOTE: The front-matter is unchanged during pull operations.

## Requirements

- **macOS** with Apple Notes
- **[Pandoc](https://pandoc.org/installing.html)** for Markdown ↔ HTML conversion
- **pcregrep** for frontmatter parsing (usually pre-installed on macOS, or install via `brew install pcre`)

## Design

The tool is built in three layers:

**AppleScript** forms the core, handling all communication with Apple Notes—finding existing notes, updating content, and creating or deleting notes (the latter mostly for testing).

**Shell scripts** contain the business logic that orchestrates these AppleScript operations, managing the sync workflow and front-matter processing.

**[Pandoc](https://pandoc.org)** handles the conversion between Markdown and HTML, ensuring content is properly formatted for Apple Notes.

**[`Bashly`](https://bashly.dev)** ties it all together, providing a clean CLI interface, shell completions, and command scaffolding.

## Development

### Setup

Clone the repository and build:

```bash
git clone https://github.com/shakedlokits/stash.git
cd stash
make build
```

### Running Tests

```bash
# Run all tests (requires Apple Notes access)
make test

# Run unit tests only (no Apple Notes required)
make test-unit
```

### Project Structure

```
src/
  lib/           # Utility functions (pure and integration)
  bashly.yml     # CLI configuration
  *_command.sh   # Command implementations
test/
  cases/         # Test specs (unit, integration, e2e)
  fixtures/      # Test fixture files
  approvals/     # Approval test snapshots
dist/
  stash          # Generated CLI (via bashly)
Formula/
  stash.rb       # Homebrew formula
```

### Creating a Release

```bash
make release VERSION=x.y.z
```

This will:
1. Update the version in `src/bashly.yml`
2. Commit the change
3. Create and push a git tag
4. Trigger the release workflow (build, publish, update Homebrew formula)


## Backlog & Contribution

This backlog contains both current and future development items, feel free to take some or add to it:
- [x] Basic Functionality
   - [x] AppleScript notes access functions
      - [x] Find note
      - [x] Create note
      - [x] Delete note
      - [x] Update note
      - [x] Read note
   - [x] Markdown front-matter parser (get-id, extract, strip, update)
   - [x] Push command shell script
   - [x] Push command tests
   - [x] Pull command shell script
   - [x] Pull command tests
   - [x] `Pandoc` integration
   - [x] `Bashly` setup
      - [x] CLI interface
      - [x] Shell completion
      - [ ] Documentation
      - [x] Approval testing
- [ ] Nice to have
   - [ ] Diff changes (requires design)
   - [ ] Attachments support
