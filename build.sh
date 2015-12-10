#!/usr/bin/env bash

# This script will run the unit tests inside a docker container.
# This is useful for running on a continuous integration server
# that has a complex environment

sudo docker build -t academic_benchmarks_specs .
sudo docker run academic_benchmarks_specs
