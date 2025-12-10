#!/usr/bin/env bash

source approvals.bash

describe "root command"

  approve "$CLI_PATH" "root_command"

  approve "$CLI_PATH --help" "root_command_help"
