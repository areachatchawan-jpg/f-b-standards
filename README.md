# F&B Standards · Multi-user Cloud Version

This build keeps the existing UI and adds:

- Supabase Postgres shared data for inspections and complaints
- Realtime updates across browsers
- Supabase Storage for inspection evidence photos
- Anonymous Supabase Auth for authenticated database access
- LocalStorage remains as offline/cache fallback

## One-time setup

1. Run `fnb-supabase-setup.sql` in the Supabase SQL Editor.
2. In Supabase Dashboard → Authentication → Sign In / Providers, enable **Anonymous Sign-Ins**.
3. Get the project's **publishable key** (older projects may call it `anon` key).
4. Open `index.html` and replace:

```js
key: 'PASTE_YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY_HERE'
```

with the public publishable/anon key.
5. Upload this `index.html` plus the `images/` folder to GitHub Pages.

Never use a `service_role` or secret key in the browser.

## Important

This version uses anonymous Supabase Auth for the shared data layer. The existing app login screen is still the current UI role gate. For stronger production security, migrate the four local roles to Supabase Auth email/password accounts and enforce role-based RLS policies.
