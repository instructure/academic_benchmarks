#!/usr/bin/env bash

echo 'Building docker image academic_benchmarks_specs'
docker build -t academic_benchmarks_specs .

# You'll need to export valid credentials and ACADEMIC_BENCHMARKS_RUN_LIVE=1 to
# run integration tests

echo 'Running the regular unit tests'
docker run \
  -e ACADEMIC_BENCHMARKS_RUN_LIVE=${ACADEMIC_BENCHMARKS_RUN_LIVE:-0} \
  -e ACADEMIC_BENCHMARKS_PARTNER_ID=${ACADEMIC_BENCHMARKS_PARTNER_ID:-empty} \
  -e ACADEMIC_BENCHMARKS_PARTNER_KEY=${ACADEMIC_BENCHMARKS_PARTNER_KEY:-empty} \
  academic_benchmarks_specs bundle exec rspec
