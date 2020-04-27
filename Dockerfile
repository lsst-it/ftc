FROM ruby:2.6

RUN mkdir /app
WORKDIR /app
ADD bin lib ftc.gemspec Gemfile Gemfile.lock /app/
RUN bundle update --bundler
RUN bundle config set system true && bundle update --bundler
ENTRYPOINT ["bundle exec ftc"]
