#!/bin/bash

# exit on error
set -o errexit

npm install &&
  mix deps.update --all
