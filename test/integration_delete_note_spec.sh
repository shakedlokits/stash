#!/usr/bin/env bash

# WARNING: This test creates and deletes actual Apple Notes
# Make sure you're running in a test environment

source approvals.bash
source "$LIB_PATH/create_note.sh"
source "$LIB_PATH/delete_note.sh"

describe "delete_note"
  
  # Test deleting existing note
  note_id=$(create_note "[TEST] Note to be deleted by integration test")
  allow_diff "x-coredata:\/\/.*"
  approve "delete_note \"\$note_id\"" "delete_note_existing"
  
  # Test deleting non-existing note (should fail gracefully)
  approve "delete_note 'x-coredata://FAKE/ICNote/p999' || echo \"Exit code: \$?\"" "delete_note_non_existing"

unset note_id
