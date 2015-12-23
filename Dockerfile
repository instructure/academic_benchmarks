FROM ruby:2.1

# The locale must be UTF-8 for the json fixtures
# to be interpreted correctly by ruby
ENV LANG C.UTF-8

RUN mkdir /app
WORKDIR /app
COPY . /app

RUN gem build academic_benchmarks.gemspec
RUN bundle install
RUN gem install --local academic_benchmarks

COPY docker_assets/irbrc.txt /root/.irbrc
CMD irb -r academic_benchmarks
