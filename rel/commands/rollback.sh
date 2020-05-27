#!/bin/sh
release_ctl eval --mfa "HybridBlog.Release.rollback/1" --argv -- "$@"
