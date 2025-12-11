#!/usr/bin/env bash

# WARNING: This test creates and deletes actual Apple Notes
# Make sure you're running in a test environment

source approvals.bash
source "$LIB_PATH/create_note.sh"
source "$LIB_PATH/read_note.sh"
source "$LIB_PATH/update_note.sh"
source "$LIB_PATH/delete_note.sh"

describe "update_note"
  
  # Test updating existing note
  note_id=$(create_note "[TEST] Original content")
  allow_diff "x-coredata:\/\/.*"
  approve "update_note \"\$note_id\" \"[TEST] Updated content\"" "update_note_existing"
  
  # Verify content was updated
  updated_content=$(read_note "$note_id")
  approve "echo \"\$updated_content\"" "update_note_verify_content"
  delete_note "$note_id" > /dev/null 2>&1
  
  # Test updating non-existing note (should fail gracefully)
  approve "update_note 'x-coredata://FAKE/ICNote/p999' 'content' || echo \"Exit code: \$?\"" "update_note_non_existing"

unset note_id
unset updated_content
