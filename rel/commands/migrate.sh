#!/bin/sh
info "starting migration"
release_ctl eval --mfa "HybridBlog.Release.migrate/1" --argv -- "$@"
success "migration completed"
