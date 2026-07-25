# Use SQLite for local application data

Rikit stores sanitized logs, retention preferences, and privacy-safe activity aggregates in one local SQLite database because filtering, expiration, and date-range aggregation need reliable queries without loading whole files into memory. Flat files would complicate those operations, while a remote service such as PocketBase would add unnecessary deployment and privacy concerns at this stage; the persistence boundary should remain replaceable if synchronization is introduced later.
