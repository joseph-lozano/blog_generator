#!/usr/bin/env bash
# exit on error
set -o errexit


mix deps.get

mix blog_generator.build