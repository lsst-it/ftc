FROM ruby:2.6

ENV BUNDLE_APP_CONFIG "/usr/local/bundle"
ENV GEM_HOME "/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH:/app/bin

RUN mkdir /app
WORKDIR /app
COPY bin /app/bin
COPY lib /app/lib
COPY ftc.gemspec Gemfile Gemfile.lock /app/
RUN /usr/local/bin/bundle config set system true && bundle install --jobs=16
ENTRYPOINT ["/usr/local/bin/bundle", "exec", "ftc"]
