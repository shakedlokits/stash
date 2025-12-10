#!/usr/bin/env bash

source approvals.bash
source "$LIB_PATH/markdown_to_html.sh"

describe "markdown_to_html"
  
  # Test 1: Simple text
  fixture=$(cat "$FIXTURES_PATH/simple.md")
  approve "echo \"\$fixture\" | markdown_to_html" "markdown_to_html_simple"
  unset fixture
  
  # Test 2: Formatted text (bold, italic, code)
  fixture=$(cat "$FIXTURES_PATH/formatted.md")
  approve "echo \"\$fixture\" | markdown_to_html" "markdown_to_html_formatted"
  unset fixture
  
  # Test 3: Lists
  fixture=$(cat "$FIXTURES_PATH/lists.md")
  approve "echo \"\$fixture\" | markdown_to_html" "markdown_to_html_lists"
  unset fixture
  
  # Test 4: Empty content
  fixture=$(cat "$FIXTURES_PATH/empty.md")
  approve "echo \"\$fixture\" | markdown_to_html" "markdown_to_html_empty"
  unset fixture
