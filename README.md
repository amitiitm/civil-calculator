# BuildEstimate - Smart Home Construction Calculator

A Ruby on Rails application that turns plot dimensions, floor layouts, and room
configurations into a detailed residential construction material quantity and
cost estimate (Phase 1 MVP), priced in INR for the Indian market.

**This is a preliminary estimation tool.** It is not a substitute for structural
engineering calculations, approved architectural plans, soil testing, local
building regulations, or certified quantity surveying. Column sizes, reinforcement,
and foundation design shown by the calculator must be verified by a qualified
structural engineer. Sample material rates in `db/seeds.rb` are illustrative only,
not live market prices.

##
Start it with cd /Users/amitpand/Documents/MyWorkspace/civil-calculator && bin/dev — dev 
admin login is admin@buildestimate.test / Password123!.

## Tech Stack

- Ruby 3.3, Rails 8.0 (Propshaft, Importmap, Turbo/Stimulus - no Node/Yarn required)
- MySQL (mysql2)
- Tailwind CSS (`tailwindcss-rails`, standalone binary - no Node build step)
- Devise (authentication) + Pundit (authorization)
- Prawn / prawn-table (PDF BOQ export), caxlsx (Excel BOQ export)
- Chartkick + Chart.js (loaded via CDN) for cost dashboards
- RSpec, FactoryBot, Shoulda Matchers, Faker

## Local Setup (macOS)

1. **Ruby**: install Ruby 3.3.x (via rbenv/rvm).
2. **MySQL**: install and run MySQL 8.x, reachable via a local socket or host.
   This project reads connection settings from environment variables (see
   `config/database.yml`), so a dedicated/isolated MySQL instance is fine -
   it does not need to be the system default:

   ```bash
   export DB_USERNAME=root
   export DB_PASSWORD=
   export DB_HOST=localhost
   export DB_SOCKET=/tmp/mysql.sock   # or your instance's socket path
   ```

3. **Install gems**:

   ```bash
   bundle install
   ```

4. **Create and migrate the database**:

   ```bash
   bin/rails db:create db:migrate db:seed
   ```

   Seeding creates material categories/materials, construction settings,
   calculation formulas, construction packages, sample labour rates, and (in
   development only) an admin login:
   `admin@buildestimate.test` / `Password123!` - change before any shared use.

5. **Run the app**:

   ```bash
   bin/dev        # Puma + Tailwind watcher
   # or just: bin/rails server
   ```

6. **Run tests**:

   ```bash
   bundle exec rspec
   ```

## Project Structure

- `app/services/calculations/` - the material calculation engine. Each material
  (bricks, cement, sand, aggregate, steel) has its own service object; a shared
  `MixQuantityService` provides the dry-volume mix engine used by cement/sand/
  aggregate so no single fixed consumption rate is reused across unrelated
  activities. `CostEstimatorService` orchestrates a full project estimate.
- `app/services/reports/` - PDF (Prawn) and Excel (caxlsx) BOQ export services.
- `app/policies/` - Pundit policies; project-owned resources (floors, rooms,
  doors, windows, estimates) share ownership rules via
  `OwnedByProjectPolicy`.
- `app/controllers/admin/` - the admin panel (materials, categories, settings,
  packages, calculation formulas + parameters, labour rates, user roles).
  All formula parameters are admin-editable data, never hardcoded in code or
  evaluated as arbitrary expressions.

## Known Phase 1 Simplifications

This is an intentionally-scoped MVP (per the project brief's phased rollout).
Documented simplifications, to be revisited in later phases:

- **Wall adjacency**: interior wall quantities are derived per-room from each
  room's own perimeter; shared walls between adjacent rooms are not de-duplicated.
- **Automatic engine scope**: the automatic `CostEstimatorService` currently
  computes bricks, cement, sand, aggregate, and steel (RCC slab/columns/footings)
  only. Doors, windows, tiles, paint, electrical, plumbing, and labour costs are
  modeled in the schema and admin panel but are not yet wired into the automatic
  calculation - they can be added as `EstimateLineItem` rows via the same
  service-object pattern.
- **Estimate versioning**: `Estimate` rows link to a `previous_version` directly
  (self-join) rather than a separate `EstimateVersion` table; formula/parameter
  changes are not yet snapshotted per estimate, so reproducing an old estimate's
  exact formula inputs after an admin edits a formula is not guaranteed.
- **Structural assumptions**: column size, column count, footing size, and
  steel-per-cft factors are admin-configurable illustrative defaults, not
  structural calculations. They are tagged `data_source: assumed` on every
  estimate line item and must be verified by a structural engineer.
- **Guest quick calculator**: the homepage currently routes guests to
  registration; a no-login quick-calculator flow is not yet implemented.

## Deployment

### Requirements

- A host that runs a persistent Ruby process (Puma) and a MySQL database.
  Standard shared/static hosting (e.g. basic Hostinger web hosting) does **not**
  support this - you need a Linux VM, a PaaS with a Ruby buildpack, or a
  container platform.
- Lowest-cost realistic options as of writing: a small VM (e.g. Hetzner,
  DigitalOcean, or a free-tier Oracle Cloud ARM instance) running Docker, or a
  Ruby-friendly PaaS that provides a managed MySQL add-on. Evaluate current
  free-tier availability before committing, as free tiers change frequently.

### Steps

1. Set required environment variables: `RAILS_MASTER_KEY` (from
   `config/master.key`), `CIVIL_CALCULATOR_DATABASE_PASSWORD`, `DATABASE_URL`
   or `DB_HOST`/`DB_USERNAME`/`DB_PASSWORD`, `RAILS_ENV=production`.
2. Install dependencies and precompile assets:

   ```bash
   bundle install --deployment --without development test
   bin/rails assets:precompile
   ```

3. Run migrations:

   ```bash
   bin/rails db:migrate
   ```

4. Boot the app behind HTTPS (e.g. via a reverse proxy or the bundled
   `thruster`/Kamal setup). A `config/deploy.yml` (Kamal) is included for
   container-based deployment; adjust the registry/host values before using it.
5. Health check endpoint: `GET /up` (returns 200 if the app booted without
   exceptions) - point your load balancer/uptime monitor here.

### Backup & Restore

```bash
# Backup
mysqldump -u <user> -p civil_calculator_production > backup.sql

# Restore
mysql -u <user> -p civil_calculator_production < backup.sql
```

Back up `config/master.key` separately and securely - it decrypts
`config/credentials.yml.enc` and cannot be regenerated.
