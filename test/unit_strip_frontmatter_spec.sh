#!/usr/bin/env bash

source approvals.bash
source "$LIB_PATH/strip_frontmatter.sh"

describe "strip_frontmatter"
  
  approve "cat $FIXTURES_PATH/with_apple_id.md | strip_frontmatter" \
    "strip_frontmatter_with_apple_id"

  approve "cat $FIXTURES_PATH/no_frontmatter.md | strip_frontmatter" \
    "strip_frontmatter_no_frontmatter"

  approve "cat $FIXTURES_PATH/malformed.md | strip_frontmatter" \
    "strip_frontmatter_malformed"

  approve "cat $FIXTURES_PATH/empty.md | strip_frontmatter" \
    "strip_frontmatter_empty"

  approve "cat $FIXTURES_PATH/with_frontmatter_no_id.md | strip_frontmatter" \
    "strip_frontmatter_with_frontmatter_no_id"
