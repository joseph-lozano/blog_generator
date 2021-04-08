#!/bin/bash

# Sets up a project for the first time

# exit on error
set -o errexit

asdf install &&
  npm install &&
  mix local.hex --force &&
  mix local.rebar --force &&
  mix deps.get &&
  mix compile
