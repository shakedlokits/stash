#!/usr/bin/env bash

source approvals.bash
source "$LIB_PATH/update_frontmatter.sh"

describe "update_frontmatter"
  
  fixture=$(cat $FIXTURES_PATH/no_frontmatter.md)
  approve "update_frontmatter \"\$fixture\" \"x-coredata://TEST/ICNote/p123\"" \
    "update_frontmatter_no_frontmatter"

  fixture=$(cat $FIXTURES_PATH/with_frontmatter_no_id.md)
  approve "update_frontmatter \"\$fixture\" \"x-coredata://TEST/ICNote/p123\"" \
    "update_frontmatter_append_to_existing"

  fixture=$(cat $FIXTURES_PATH/with_apple_id.md)
  approve "update_frontmatter \"\$fixture\" \"x-coredata://NEW-ID/ICNote/p999\"" \
    "update_frontmatter_update_existing"

  fixture=$(cat $FIXTURES_PATH/empty.md)
  approve "update_frontmatter \"\$fixture\" \"x-coredata://TEST/ICNote/p123\"" \
    "update_frontmatter_empty"

  fixture=$(cat $FIXTURES_PATH/malformed.md)
  approve "update_frontmatter \"\$fixture\" \"x-coredata://TEST/ICNote/p123\"" \
    "update_frontmatter_malformed"

unset fixture
