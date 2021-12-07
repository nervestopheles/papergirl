FROM docker.io/ruby:3.0.3

ENV DIR='/app'
RUN mkdir -p ${DIR}
WORKDIR ${DIR}

COPY ["Gemfile", "Gemfile.lock", "./"]
RUN bundle install

COPY ["./", "./"]
EXPOSE 8090

CMD ["ruby", "main.rb"]
