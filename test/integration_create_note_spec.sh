#!/usr/bin/env bash

# WARNING: This test creates and deletes actual Apple Notes
# Make sure you're running in a test environment

source approvals.bash
source "$LIB_PATH/create_note.sh"
source "$LIB_PATH/delete_note.sh"

describe "create_note"
  
  # Test creating note with content
  allow_diff "x-coredata:\/\/.*"
  note_id=$(create_note "[TEST] Note created by integration test - create_note")
  approve "echo \"\$note_id\"" "create_note_with_content"
  delete_note "$note_id" > /dev/null 2>&1

unset note_id
