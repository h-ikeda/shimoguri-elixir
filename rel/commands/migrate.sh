#!/bin/sh
release_ctl eval --mfa "HybridBlog.Release.migrate/1" --argv -- "$@"
