---
id: arch.authentication
title: Authentication
type: architecture
compressed: 'Supabase Auth(email/pw,OAuth);session managed by Supabase client
Custom access token hook embeds org_id and user_role
Roles: admin,manager,member,viewer,external
Org switch triggers refreshSession()→invalidate queries,reconnect Realtime
Protected routes via guard;OAuth handled by Supabase
JWT forwarding via ~services/api.ts;401 triggers refresh→retry'
Roles: admin,manager,member,viewer,external
last_updated: '2026-04-24T23:37:09.423638+00:00'
---

# Authentication

Supabase Auth(email/pw,OAuth);session managed by Supabase client
Custom access token hook embeds org_id and user_role
Roles: admin,manager,member,viewer,external
Org switch triggers refreshSession()→invalidate queries,reconnect Realtime
Protected routes via guard;OAuth handled by Supabase
JWT forwarding via ~services/api.ts;401 triggers refresh→retry
