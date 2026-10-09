# Web Application Template (`web-template`)

![Angular](https://img.shields.io/badge/Angular-v22-DD0031?logo=angular&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-6.0-3178C6?logo=typescript&logoColor=white)
![Azure SWA](https://img.shields.io/badge/Azure-Static%20Web%20App-0078D4?logo=microsoftazure&logoColor=white)
![Node](https://img.shields.io/badge/Node.js-22.22.3-339933?logo=nodedotjs&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-lightgrey)

This repository serves as an Angular v22 single-page application template. The template is pre-configured for hosting on **Azure Static Web Apps** and automates deployments via **Gitea Actions** on every merge to `main`.

The UI layout is assembled from **five Git submodule components** — header, carousel, partner showcase, offerings grid, and footer — each maintained in its own repository under the `DTIG-US` organization.

---

## 📋 Table of Contents

- [Tech Stack](#-tech-stack)
- [Application Layout](#-application-layout)
- [Quick Start / Installation](#-quick-start--installation)
- [Usage — Key Commands](#-usage--key-commands)
  - [Development](#development)
  - [Git Submodules](#git-submodules)
  - [Infrastructure & Deployment](#infrastructure--deployment)
- [Examples & Demos](#-examples--demos)
- [Component Submodules Overview](#-component-submodules-overview)
- [Automation & Helper Scripts](#️-automation--helper-scripts)
- [Documentation](#-documentation)

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Angular v22](https://angular.dev) (standalone components, Signals, lazy routing) |
| Language | TypeScript 6.0 (strict mode) |
| Styling | Vanilla CSS + Bootstrap 5 |
| Carousel | [ngx-carousel-ease](https://www.npmjs.com/package/ngx-carousel-ease) |
| Testing | Karma + Jasmine (unit), Playwright (e2e) |
| Infrastructure | Terraform → Azure Static Web Apps |
| CI/CD | Gitea Actions (`.gitea/workflows/deploy.yml`) |
| Node version | `22.22.3` (pinned in `.nvmrc`) |

---

## 🏗️ Application Layout

The shell (`app.html`) acts as a persistent layout wrapper — only the main content area swaps per route:

```
app-root
 ├── <app-header>        ← always rendered (navigation, branding)
 ├── <router-outlet>     ← swaps in the active route component
 └── <app-footer>        ← always rendered (copyright, legal links)
```

**Route table:**

| Path | Component | Description |
|---|---|---|
| `/` | `HomeComponent` | Hero carousel, partners, demo, offerings |
| `/privacy-policy` | `PrivacyPolicyComponent` | Privacy policy (static) |
| `/terms-of-service` | `TermsOfServiceComponent` | Terms of service (static) |
| `**` | `NotFoundComponent` | 404 fallback |

All routes are **lazy-loaded** via `loadComponent()`. The `staticwebapp.config.json` rewrites all unknown paths to `/index.html` so Angular's router handles navigation.

---

## 🚀 Quick Start / Installation

### Prerequisites

| Tool | Required Version | Notes |
|---|---|---|
| [Node.js](https://nodejs.org/) | `22.22.3` (LTS) | Pinned in `.nvmrc` — use `nvm use` |
| [npm](https://www.npmjs.com/) | ≥ 10 | Bundled with Node |
| [Angular CLI](https://angular.dev/tools/cli) | ≥ 22 | `npm install -g @angular/cli` |
| [Git](https://git-scm.com/) | Any | Required for submodule support |

> [!TIP]
> If you use [nvm](https://github.com/nvm-sh/nvm), run `nvm use` in the project root to automatically switch to Node 22.22.3.

### Step 1 — Clone with submodules

```bash
git clone --recurse-submodules https://github.com/DTIG-US/web-template.git
cd web-template
```

If you already cloned without `--recurse-submodules`, initialize them now:

```bash
git submodule update --init --recursive
```

### Step 2 — Install dependencies

```bash
npm install
```

### Step 3 — Run the automated setup script

For a fresh clone, run the one-step setup script to patch submodule components for Angular v22 compatibility and apply global styles:

```bash
./tools/development-tools/02_getting_started.sh
```

### Step 4 — Start the dev server

```bash
npm start
```

Open `http://localhost:4200/` in your browser. The app hot-reloads on file changes.

---

## 💻 Usage — Key Commands

### Development

```bash
# Start local dev server (http://localhost:4200)
npm start

# Build for production
npm run build

# Watch-mode build (development, incremental)
npm run watch

# Run unit tests (Karma + Jasmine)
npm test

# Test the production build locally via SWA emulator
npx swa start dist/angular-project/browser --config staticwebapp.config.json
```

### Git Submodules

```bash
# Initialize / sync all submodules to their pinned commits
./tools/development-tools/04_updating_stale_submodules.sh

# Safely commit and push submodules + parent in one step
./tools/development-tools/03_commiting_with_submodule_handling.sh -m "your commit message"

# Commit a specific submodule only
./tools/development-tools/03_commiting_with_submodule_handling.sh -m "fix: header nav" -s src/app/web-header

# Dry-run (preview what would be committed)
./tools/development-tools/03_commiting_with_submodule_handling.sh -m "style: layout" -n
```

> [!WARNING]
> Always use `03_commiting_with_submodule_handling.sh` (or manually push submodules first) before committing the parent repo. Committing a parent pointer to an unpushed submodule SHA will break the repo for other contributors.

### Infrastructure & Deployment

```bash
# Provision infrastructure for an environment
./tools/deployment-tools/www_terraform_deploy.sh dev        # or staging / prod

# Deploy the built app to Azure SWA
./tools/deployment-tools/www_swa_deploy.sh dev              # or staging / prod

# Destroy a provisioned environment
./tools/deployment-tools/www_terraform_destroy.sh dev
```

Full Terraform + CI/CD documentation: **[doc/deployment.md](doc/deployment.md)**

---

## 🎬 Examples & Demos

### Page Structure (rendered layout)

```
┌─────────────────────────────────┐
│           <app-header>          │  Navigation bar, logo, primary menu
├─────────────────────────────────┤
│         <app-carousel>          │  Hero banner / news carousel
├─────────────────────────────────┤
│         <app-partners>          │  Partner logo slider
├─────────────────────────────────┤
│        <app-handsani-demo>      │  Interactive product demo
├─────────────────────────────────┤
│         <app-offering>          │  Product / service feature grid
├─────────────────────────────────┤
│           <app-footer>          │  Copyright, Privacy Policy, ToS
└─────────────────────────────────┘
```

### Example: Running a dev build

```bash
$ npm start

> web-template@1.0.0 start
> ng serve

✔ Browser application bundle generation complete.
Watch mode enabled. Watching for file changes...
  ➜  Local:   http://localhost:4200/
```

### Example: Deploying to staging

```bash
$ ./tools/deployment-tools/www_terraform_deploy.sh staging

==> Selecting Terraform workspace: staging...
==> Running terraform apply...
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

$ ./tools/deployment-tools/www_swa_deploy.sh staging

==> Retrieving Terraform outputs for workspace: staging...
==> Building Angular application...
==> Deploying dist/angular-project/browser to Azure Static Web App...
==> Deployment completed successfully!
```

---

## 📦 Component Submodules Overview

| Component Path | Selector | Repository | Description |
|---|---|---|---|
| [`src/app/web-header`](src/app/web-header) | `<app-header>` | [web-header](https://github.com/DTIG-US/web-header) | Navigation header, company branding, primary menu |
| [`src/app/web-carousel`](src/app/web-carousel) | `<app-carousel>` | [web-carousel](https://github.com/DTIG-US/web-carousel) | Hero banner carousel and news feed panel |
| [`src/app/web-partner`](src/app/web-partner) | `<app-partners>` | [web-partner](https://github.com/DTIG-US/web-partner) | Partner logo showcase and affiliate link slider |
| [`src/app/web-offering`](src/app/web-offering) | `<app-offering>` | [web-offering](https://github.com/DTIG-US/web-offering) | Product and service feature matrix grid |
| [`src/app/web-footer`](src/app/web-footer) | `<app-footer>` | [web-footer](https://github.com/DTIG-US/web-footer) | Footer, copyright, privacy policy, social links |

> [!IMPORTANT]
> Each submodule is **pinned to a specific commit**. Changes inside a submodule folder must be committed and pushed *inside* that submodule repository first, then the updated pointer committed in this parent repo. Use [`tools/development-tools/03_commiting_with_submodule_handling.sh`](tools/development-tools/03_commiting_with_submodule_handling.sh) to handle this automatically.

---

## 🛠️ Automation & Helper Scripts

Scripts in [`tools/development-tools/`](tools/development-tools/) simplify common development tasks:

| Script | Purpose |
|---|---|
| [`01_add_submodules.sh`](tools/development-tools/01_add_submodules.sh) | Registers and clones all five UI submodules into `src/app/` via `git submodule add`. |
| [`02_getting_started.sh`](tools/development-tools/02_getting_started.sh) | Full onboarding setup: patches component files to standalone, copies CSS, updates `angular.json`. |
| [`03_commiting_with_submodule_handling.sh`](tools/development-tools/03_commiting_with_submodule_handling.sh) | Safely commits and pushes submodule changes **before** updating the parent repo pointer. Supports `-m`, `-s`, `-n` (dry-run) flags. |
| [`04_updating_stale_submodules.sh`](tools/development-tools/04_updating_stale_submodules.sh) | Runs `git submodule update --init --recursive` to sync all submodules to their pinned commits. |
| [`05_create_new_branch.sh`](tools/development-tools/05_create_new_branch.sh) | Creates a named branch simultaneously in the parent repo and all submodules. |
| [`06_pr_on_all_submodules.sh`](tools/development-tools/06_pr_on_all_submodules.sh) | Opens a GitHub PR for every submodule's current branch via `gh` CLI. |

Infrastructure scripts in [`tools/deployment-tools/`](tools/deployment-tools/):

| Script | Purpose |
|---|---|
| [`www_terraform_deploy.sh`](tools/deployment-tools/www_terraform_deploy.sh) | Provisions Azure SWA resources for `dev`, `staging`, or `prod` via Terraform. |
| [`www_swa_deploy.sh`](tools/deployment-tools/www_swa_deploy.sh) | Builds the Angular app and deploys it to the target Azure SWA environment. |
| [`www_terraform_destroy.sh`](tools/deployment-tools/www_terraform_destroy.sh) | Tears down a provisioned environment's Terraform-managed infrastructure. |

---

## 📄 Documentation

| Document | Description |
|---|---|
| [`doc/deployment.md`](doc/deployment.md) | Full deployment guide: Terraform setup, CI/CD pipeline, manual SWA deploy, and local SWA testing. |
| [`doc/Migration_Documentation.md`](doc/Migration_Documentation.md) | Converting template components to standalone, registering `SlickCarouselModule`, patching `angular.json`, and syncing global CSS. |
| [`doc/README_AligningComponents.md`](doc/README_AligningComponents.md) | Offerings & Partners alignment work — alternating backgrounds, glassmorphism, layout delineation, and accessibility. |
| [`doc/Tips_and_Tricks.md`](doc/Tips_and_Tricks.md) | Quick reference for submodule operations: syncing, recovering dirty references, cleaning uncommitted changes. |

Other key project files:

- [AGENTS.md](AGENTS.md) — Angular and TypeScript development guidelines for AI and human contributors.
- [AUTHORS.md](AUTHORS.md) — Project contributors.
- [SECURITY.md](SECURITY.md) — Security policy and vulnerability reporting.
- [CODE-OF-CONDUCT.md](CODE-OF-CONDUCT.md) — Contributor code of conduct.
- [NEWS.md](NEWS.md) — Release notes and changelog.
