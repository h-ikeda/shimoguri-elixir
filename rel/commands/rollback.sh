#!/bin/sh
info "starting rollback"
release_ctl eval --mfa "HybridBlog.Release.rollback/1" --argv -- "$@"
success "rollback completed"
