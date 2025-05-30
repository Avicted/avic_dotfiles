#!/bin/bash

# Utility function to find interesting notes in the source code
egrep --color --exclude-dir={node_modules,build} --exclude=todos.sh -irnw '.' -e '@Todo|@Note|@Performance|@Perf|@Security'
