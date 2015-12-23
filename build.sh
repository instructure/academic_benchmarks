#!/usr/bin/env bash

# This script will run the unit tests inside a docker container.
# This is useful for running on a continuous integration server
# that has a complex environment

echo 'Building docker image academic_benchmarks_specs'
sudo docker build -t academic_benchmarks_specs .

echo 'Running the regular unit tests'
sudo docker run academic_benchmarks_specs bundle exec rspec spec

#
# run the tests that require credentials
# this can be commented out if you don't have Academic Benchmark
# API credentials, or if you don't want to wait for the slower tests
#
# Note that this expects the local environment to have
# ACADEMIC_BENCHMARKS_PARTNER_ID and ACADEMIC_BENCHMARKS_PARTNER_KEY
# set with the respective Academic Benchmarks API credential
#
echo 'Running live API tests'
sudo -E docker run \
  -e 'ACADEMIC_BENCHMARKS_RUN_LIVE=1' \
  -e 'ACADEMIC_BENCHMARKS_PARTNER_ID' \
  -e 'ACADEMIC_BENCHMARKS_PARTNER_KEY' \
  academic_benchmarks_specs bundle exec rspec spec
