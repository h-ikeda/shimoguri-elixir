#!/bin/sh
info "seeding user roles"
release_ctl eval --mfa "HybridBlog.Release.authorize_first_user/1" --argv -- "$@"
success "seeding completed"
