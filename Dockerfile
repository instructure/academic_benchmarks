FROM ruby:2.6-slim

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    # Required for building `bigdecimal`
    build-essential \
    # Required, because original versions in `-slim` are vulnerable according to Snyk
    libc-dev-bin libc6-dev libc-bin libc6 && \
    # Clear cache
  apt-get clean && rm -rf /var/lib/apt/lists/*

# The locale must be UTF-8 for the json fixtures
# to be interpreted correctly by ruby
ENV LANG C.UTF-8

RUN mkdir /app
WORKDIR /app
COPY Gemfile academic_benchmarks.gemspec /app/

RUN bundle install

COPY . /app/
RUN gem build academic_benchmarks.gemspec
RUN gem install --local academic_benchmarks

COPY docker_assets/irbrc.txt /root/.irbrc
CMD irb -r academic_benchmarks
