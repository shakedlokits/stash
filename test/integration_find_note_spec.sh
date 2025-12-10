#!/usr/bin/env bash

# WARNING: This test creates and deletes actual Apple Notes
# Make sure you're running in a test environment

source approvals.bash
source "$LIB_PATH/create_note.sh"
source "$LIB_PATH/find_note.sh"
source "$LIB_PATH/delete_note.sh"

describe "find_note"
  
  # Test finding existing note
  allow_diff "x-coredata:\/\/.*"
  note_id=$(create_note "[TEST] Note created by integration test - find_note")
  found_id=$(find_note "$note_id")
  approve "echo \"\$found_id\"" "find_note_existing"
  delete_note "$note_id" > /dev/null 2>&1
  
  # Test finding non-existing note (should fail gracefully)
  approve "find_note 'x-coredata://FAKE/ICNote/p999' || echo \"Exit code: \$?\"" "find_note_non_existing"

unset note_id
unset found_id
