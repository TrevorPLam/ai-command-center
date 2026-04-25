---
id: arch.auth
title: AUTH
type: architecture
status: draft
version: 1.0.0
compressed: |
Supabase Auth(email/pw,OAuth);session managed by Supabase client
Custom access token hook embeds org_id and user_role
Roles: admin,manager,member,viewer,external
Org switch triggers refreshSession()→invalidate queries,reconnect Realtime
Protected routes via guard;OAuth handled by Supabase
JWT forwarding via ~services/api.ts;401 triggers refresh→retry
last_updated: 2026-04-24T23:22:41.112198+00:00
---

# AUTH

Supabase Auth(email/pw,OAuth);session managed by Supabase client
Custom access token hook embeds org_id and user_role
Roles: admin,manager,member,viewer,external
Org switch triggers refreshSession()→invalidate queries,reconnect Realtime
Protected routes via guard;OAuth handled by Supabase
JWT forwarding via ~services/api.ts;401 triggers refresh→retry
