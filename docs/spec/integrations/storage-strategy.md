---
id: integration.storage-strategy
title: Storage Strategy
type: integration
compressed: '| Aspect | Details |

  |--------|----------|

  | Buckets | `org-{id}/documents`, `org-{id}/media`, `org-{id}/email-attachments`,
  `public/avatars` |

  | Access | All Supabase Storage ops through StorageService wrapper (GC6) |

  | Transforms | Image optimization (WebP, AVIF), blurhash generation, thumbnail creation
  |

  | Malware Scanning | ClamAV WASM on upload → clean or quarantine |

  | Quota | Per‑org limits tracked in `organizations` table |

  | Upload | Multipart chunked with progress, abort, retry 3× |

  | File Validation | MIME type check, size limits, extension whitelist |'
last_updated: '2026-04-25T01:34:38.858588+00:00'
---

# Storage Strategy

| Aspect | Details |
|--------|----------|
| Buckets | `org-{id}/documents`, `org-{id}/media`, `org-{id}/email-attachments`, `public/avatars` |
| Access | All Supabase Storage ops through StorageService wrapper (GC6) |
| Transforms | Image optimization (WebP, AVIF), blurhash generation, thumbnail creation |
| Malware Scanning | ClamAV WASM on upload → clean or quarantine |
| Quota | Per‑org limits tracked in `organizations` table |
| Upload | Multipart chunked with progress, abort, retry 3× |
| File Validation | MIME type check, size limits, extension whitelist |
