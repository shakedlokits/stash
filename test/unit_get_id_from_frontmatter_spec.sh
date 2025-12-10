#!/usr/bin/env bash

source approvals.bash
source "$LIB_PATH/get_id_from_frontmatter.sh"

describe "get_id_from_frontmatter"
  
  fixture=$(cat $FIXTURES_PATH/with_apple_id.md)
  approve "get_id_from_frontmatter \"\$fixture\"" \
    "get_id_from_frontmatter_with_apple_id"

  fixture=$(cat $FIXTURES_PATH/no_frontmatter.md)
  approve "get_id_from_frontmatter \"\$fixture\" || echo \"Exit code: \$?\"" \
    "get_id_from_frontmatter_no_frontmatter"

  fixture=$(cat $FIXTURES_PATH/with_frontmatter_no_id.md)
  approve "get_id_from_frontmatter \"\$fixture\" || echo \"Exit code: \$?\"" \
    "get_id_from_frontmatter_no_apple_notes_id"

  fixture=$(cat $FIXTURES_PATH/malformed.md)
  approve "get_id_from_frontmatter \"\$fixture\" || echo \"Exit code: \$?\"" \
    "get_id_from_frontmatter_malformed"

  fixture=$(cat $FIXTURES_PATH/empty.md)
  approve "get_id_from_frontmatter \"\$fixture\" || echo \"Exit code: \$?\"" \
    "get_id_from_frontmatter_empty"

unset fixture
