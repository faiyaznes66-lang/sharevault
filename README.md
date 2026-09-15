# ShareVault

ShareVault is a secure file-sharing and creator monetization platform. Users can upload files, create shareable links, track views and downloads, analyze traffic, and track estimated earnings from qualified visits.

## Current status — V0.1

The repository now contains a responsive React/Vite frontend plus the initial production backend blueprint. Real payouts are **not enabled** and all earnings shown in the preview are demo estimates.

## Run locally

```bash
npm install
npm run dev
```

For a production build:

```bash
npm run build
```

## Backend setup

The recommended V0.1 backend is Supabase (Auth, Postgres and Storage). Copy `.env.example` to `.env` and provide your project URL and public anon key. Run `supabase/schema.sql` in the Supabase SQL editor.

Never commit a Supabase service-role key or payment-provider secret. Qualification of traffic, wallet credits and payouts must happen on trusted server-side code, not in the browser.

See `docs/ARCHITECTURE.md` for the rollout plan covering storage, signed downloads, anti-fraud, file safety, analytics and future payouts.

## Earnings preview

The UI currently demonstrates a CPM of **$1.50 per 1,000 qualified views**:

`Estimated Earnings = Qualified Views / 1000 × CPM`

This is a demo model, not a promise of earnings.
