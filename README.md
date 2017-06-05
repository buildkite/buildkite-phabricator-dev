buildkite-phabricator-dev
=========================

A Dockerized environment for developing and testing our [buildkite-patches branch of Phabricator](https://github.com/buildkite/phabricator/tree/buildkite-support).

## Getting Started

```bash
# Clone this repo
git clone https://github.com/phacility/docker-phabricator.git
cd docker-phabricator

# Clone our patches branch (based offf stable)
git clone -b buildkite-patches https://github.com/buildkite/phabricator.git

# Clone the stable versions
git clone https://github.com/phacility/libphutil.git
git clone https://github.com/phacility/arcanist.git

# Bootstrap the database
docker-compose up
docker-compose run --rm phabricator ./bin/storage upgrade --force

# Setup up Pow, or somesuch
echo '8081' > '~/.pow/phabricator'

# Start it up
docker-compose up

# Give it a go
open http://phabricator.dev/
```

The local phabricator, libphutil and arcanist checkouts will be mounted into the container at `/opt`

## Helpful development snippets

Getting a bash prompt:

```bash
docker-compose run --rm phabricator bash
```

## License

MIT (see [LICENSE](LICENSE))