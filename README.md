# Academic Benchmarks Ruby Library

_Brought to you by your friends at [Instructure](https://www.instructure.com/)_ :heart:

## What is Academic Benchmarks?

[Academic Benchmarks](http://academicbenchmarks.com/) provides an API that allows a user with a subscription to download various [CBE standards](http://www.competencyworks.org/analysis/what-is-the-difference-between-standards-based-grading/).

## Why use this library?

* So you don't have to implement your own authentication
* To avoid dealing with raw endpoints
* Beating the pains of de-pagination
* For trees that actually work
* Re-using code is smart

## Get Started

This library mirrors the Academic Benchmarks API in order to make it easy to figure out what to do.  Once you get a `Handle` object, the rest is fairly intuitive.

### Install this gem

If you are developing an application, you should add `academic_benchmarks` to your `Gemfile`:

    gem 'academic_benchmarks', '<current-version>'

Of course you can also just install the gem by itself:

    gem install academic_benchmarks

### Get some credentials

First you need some credentials (a "Partner ID" and a "Partner Key").  Either get some by paying Academic Benchmarks a pile of money, or by [signing up for a sandbox account](http://docs.academicbenchmarks.com/#?d=support&f=request_demo).

### Get a Handle

A `Handle` is how you interact with the API.  You can think of a handle as a configured connection that you can call methods on, and the rest "just works" &trade;

You can get your credentials into the library in either of two ways.  The way you choose probably depends on whether you're in production or test/development.  The environment variables are better practice for production, while the direct pass-in parameters are more convenient for development.

Pass-in credentials directly:

    ab_handle = AcademicBenchmarks::Api::Handle.new(partner_id: 'my-id', partner_key: 'my-key')

Or set environment variables:

    export ACADEMIC_BENCHMARKS_PARTNER_ID='my-id'
    export ACADEMIC_BENCHMARKS_PARTNER_KEY='my-key'

And instantiate:

    ab_handle = AcademicBenchmarks::Api::Handle.init_from_env

### Do Something

Now use the handle to get standards, either by searching or using convenience methods:

#### Search for standards

The parameters accepted by the search method mirror [the AB API](http://docs.academicbenchmarks.com/#?d=api&f=standards).  See those docs for an enumeration.

Search for some some text within standards:

    ab_handle.standards.search(query: "my search query")

Retrieve all standards from a certain authority (Indiana given in the example)

    ab_handle.standards.search(authority: "IN")

#### List available authorities

    ab_handle.standards.authorities

#### Retrieve all standards

NOTE: If you have a lot of standards in your subscription, _this will take a really long time_

    ab_handle.standards.all

#### Retrieve a specified guid

    ab_handle.standards.guid("<some-guid>">)

This can be restricted to certain fields.  See [the list of all available fields](http://docs.academicbenchmarks.com/#?d=api&f=standards):

    ab_handle.standards.guid("<some-guid>">, fields: %w[descr number version])

## Running Unit Tests

There are two types of unit tests.  Both types are run by rspec:

### Self-contained Unit Tests

The first type of unit tests are all self-contained and do not make any API calls to Academic Benchmarks.  The data they require is read from fixtures saved in the repo.  These tests generally run quickly and are suitable for running in any environment, with or without API credentials.  To run these tests, simply run `rspec` on the `specs/` directory:

    bundle exec rspec spec/

### Live API Unit Tests

The second type of unit tests are dependent on having valid credentials to the Academic Benchmark API, as well as a valid network connection on the box running the tests.  These tests _will actually make API calls against the Academic Benchmark API_, so use good judgment before running them.  The tests were written to be run against a sandbox account, but they are written in a manner that they should work fine against a full account as well.  To run these tests, simply set the environment variable "ACADEMIC_BENCHMARKS_RUN_LIVE" to the value 1 and run the tests as usual.  This will run all specs, including the specs that make real calls to the AB API.  Here is an example:

    ACADEMIC_BENCHMARKS_RUN_LIVE=1 bundle exec rspec spec/

If your credentials aren't already in environment variables (see [get-a-handle](#get-a-handle) for example), you can pass them directly here:

    ACADEMIC_BENCHMARKS_PARTNER_ID='my-id' ACADEMIC_BENCHMARKS_PARTNER_KEY='my-key' ACADEMIC_BENCHMARKS_RUN_LIVE=1 bundle exec rspec spec/

## Manual Testing

See TESTPLAN.md for a test plan that can be followed by a QA team to verify functionality of the library.

## Contributing

We would love some contributions!  There is detailed information in CONTRIBUTING.md, but the gist is:

1.  Match our style.  It doesn't have to be perfect but inconsistent styles in a codebase can make reading the code difficult.
1.  Write a test.  Not everything is testable, but most things are.  If you can, write a test.  If you don't know how, send a PS and we'll try to work with you.
1.  Update the documentation.  If your feature should be in the README, then add it!  Also, if it makes sense, please add a manual verification step to TESTPLAN.md.
