# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lunchies is a Rails 8.1 application for AI-powered restaurant discovery and team lunch coordination with Google Calendar integration. It uses Ruby 4.0.1, SQLite, Hotwire (Turbo + Stimulus), Tailwind CSS with DaisyUI, and the ActiveAgent framework with OpenAI.

## Common Commands

### Development
```bash
bin/setup              # Initial setup (dependencies, DB creation, migrations)
bin/dev                # Start dev server (Rails + Tailwind CSS watch)
bin/rails console      # Interactive Rails console
```

### Testing
```bash
bin/rails test                        # Run unit/integration tests
bin/rails test:system                 # Run system tests (Capybara + Selenium)
bin/rails test TEST=test/models/user_test.rb  # Run a single test file
bin/rails test TEST=test/models/user_test.rb TESTOPTS="--name=test_something"  # Single test
bin/rails db:test:prepare test        # Prepare test DB and run tests
```

### Linting & Security
```bash
bin/rubocop -f github     # Ruby linting (Omakase style)
bin/brakeman --no-pager   # Security static analysis
bin/bundler-audit          # Gem vulnerability scan
bin/importmap audit        # JS dependency audit
```

### Database
```bash
bin/rails db:migrate       # Run migrations
bin/rails db:reset         # Drop + create + migrate + seed
```

## Architecture

### Key Integrations
- **Google Sign-In**: OAuth 2.0 authentication (only auth method, no passwords)
- **Google Calendar API**: Reads calendar events for lunch scheduling; tokens stored encrypted in `calendar_connections`
- **Google Places API**: Restaurant search via `GooglePlacesService` using Faraday HTTP client
- **ActiveAgent + OpenAI**: `RestaurantFinderAgent` in `app/agents/` uses tools (search_restaurants, get_reviews) to recommend restaurants

### Authentication
- Google OAuth only — `Current.user` provides thread-safe access to the authenticated user
- `Authentication` concern in `ApplicationController` with `allow_unauthenticated_access` to bypass
- Sessions tracked in DB with IP and user agent

### Data Model
- **User** → has_many Sessions, TeamMemberships, has_one CalendarConnection
- **Team** → has_many TeamMemberships, TeamRestaurants, CalendarEvents, Lunches; stores location (lat/lng)
- **Restaurant** → has_many TeamRestaurants; stores rating, types (JSON), price_level from Google Places
- **Lunch** → belongs_to Team + Restaurant; tracks booking status and occurrence

### Credentials
Encrypted in `config/credentials.yml.enc` (requires `config/master.key` or `RAILS_MASTER_KEY`):
- `google.client_id`, `google.client_secret`, `google.places_api_key`, `google.redirect_uri`
- `openai.api_key`

### Deployment
Docker + Kamal. Puma behind Thruster for HTTP caching. SQLite data persisted via Docker volumes.
