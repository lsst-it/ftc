FROM ruby:2.7

RUN mkdir /app
WORKDIR /app
ADD ftc Gemfile Gemfile.lock /app/
RUN bundle update --bundler
RUN bundle config set system true && bundle update --bundler
ENTRYPOINT ["/app/ftc"]
