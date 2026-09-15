# ShareVault architecture

## V0.1
React/Vite client with an original ShareVault UI. Money figures are demo estimates and withdrawals are disabled.

## Recommended backend
Supabase Auth + Postgres + Storage provides the first production backend. Use private storage buckets and short-lived signed download URLs. Never expose the service-role key to the browser.

## Request flow
1. User authenticates.
2. Client requests an upload authorization.
3. File is uploaded to private object storage.
4. Metadata is stored in `files`.
5. Public `/f/:slug` page reads safe metadata only.
6. View/download events go to a trusted server/edge endpoint.
7. Server scores traffic and marks only eligible events qualified.
8. Earnings are calculated server-side and appended to the wallet ledger.

## Anti-fraud baseline
Do not qualify owner/self traffic, rapid refresh loops, repeated sessions, known bots, datacenter/proxy anomalies or impossible request rates. Store privacy-preserving hashes rather than raw IP addresses where practical. Add rate limiting and CAPTCHA/challenge escalation for suspicious traffic.

## File safety
Use allow/deny rules, file-size limits, MIME and magic-byte verification, quarantine, malware scanning before public availability, abuse reporting, copyright takedown workflow and admin moderation. Never claim a file was scanned unless scanning actually completed.

## Money and payouts
Keep estimated earnings separate from available balances. Payouts remain disabled until identity/KYC, fraud review, payment provider integration, tax/compliance requirements and reconciliation are implemented. The browser must never be authoritative for CPM, qualified views, balances or payouts.

## Deployment
Frontend: Cloudflare Pages, Vercel, Netlify or another Vite-compatible host. Backend: Supabase. Later move high-volume downloads to an object-storage/CDN architecture such as Cloudflare R2 if economics require it.
