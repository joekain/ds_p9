#!/bin/sh

. .access
mix test
mix run -e Twitter.test_runner
