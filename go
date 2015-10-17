#!/bin/sh

. .access
# mix test
# mix run -e Main.run
mix run -e Reddit.Fetcher.test
