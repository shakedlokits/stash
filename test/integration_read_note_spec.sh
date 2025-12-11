#!/usr/bin/env bash

# WARNING: This test creates and deletes actual Apple Notes
# Make sure you're running in a test environment

source approvals.bash
source "$LIB_PATH/create_note.sh"
source "$LIB_PATH/read_note.sh"
source "$LIB_PATH/delete_note.sh"

describe "read_note"
  
  # Test reading existing note
  note_id=$(create_note "[TEST] Read note integration test content")
  content=$(read_note "$note_id")
  approve "echo \"\$content\"" "read_note_existing"
  delete_note "$note_id" > /dev/null 2>&1
  
  # Test reading non-existing note (should fail gracefully)
  approve "read_note 'x-coredata://FAKE/ICNote/p999' || echo \"Exit code: \$?\"" "read_note_non_existing"

unset note_id
unset content
