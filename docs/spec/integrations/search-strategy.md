---
id: integration.search-strategy
title: Search Strategy
type: integration
compressed: '| Phase | Technology | Details |

  |-------|------------|---------|

  | Phase 1 | pg_trgm + tsvector + GIN | Keyword search |

  | Phase 2 | pgvector HNSW (m=16, ef=64) | Semantic search |

  | Phase 3 | Typesense | If degraded, hybrid keyword + semantic weighted ranking
  |

  | OCR | Tesseract.js WASM (Edge Function) | PDF/image text extraction |

  | RAG | FastAPI /v1/embed → pgvector (RLS) | |

  | Endpoint | GET /v1/search | Supports `q`, `type`, `before`, `after` |

  | Scope | Projects, tasks, events, emails, contacts, documents, news, research |
  |

  | Result shape | `{ entity_type, id, title, preview, icon, route }` | |'
last_updated: '2026-04-25T01:34:38.860163+00:00'
---

# Search Strategy

| Phase | Technology | Details |
|-------|------------|---------|
| Phase 1 | pg_trgm + tsvector + GIN | Keyword search |
| Phase 2 | pgvector HNSW (m=16, ef=64) | Semantic search |
| Phase 3 | Typesense | If degraded, hybrid keyword + semantic weighted ranking |
| OCR | Tesseract.js WASM (Edge Function) | PDF/image text extraction |
| RAG | FastAPI /v1/embed → pgvector (RLS) | |
| Endpoint | GET /v1/search | Supports `q`, `type`, `before`, `after` |
| Scope | Projects, tasks, events, emails, contacts, documents, news, research | |
| Result shape | `{ entity_type, id, title, preview, icon, route }` | |
