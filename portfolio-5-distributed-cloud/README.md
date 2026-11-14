# Portfolio 5: Distributed and Cloud Database

## Goal
Show how the CityReads Library database runs in the **cloud** as a **distributed** system: data copied across several servers (replication), staying online when a server fails (availability), and how it could be split across servers as the library grows (sharding). Also explain the consistency trade-offs this creates.

## Deployment: what I set up
The CityReads book catalogue from Portfolio 4 is deployed on **MongoDB Atlas**, a cloud database service.


| Setting | Value |
|---|---|
| Service | MongoDB Atlas (Database-as-a-Service)
| Cluster name | Cluster0 
| Tier | M0 (free) |
| Cloud provider | AWS
| Region | Paris
| Cluster type | **Replica set**, 3 nodes |
| Database / collection | `cityreads` / `catalogue` (8 documents) |
| Security | Database user with password, IP access list, encrypted connections (TLS) |

**Why the cloud?** CityReads doesn't have to buy, install or maintain servers. Atlas handles hardware, software updates, monitoring and replication. The library pays only for the size it needs, and can move to a bigger tier as it grows.

## Replication: three copies of the data
Even the free cluster is a **replica set** of **3 servers (nodes)**, each holding a full copy of the data:

| Node | Role | What it does |
|---|---|---|
| Node 1 | **Primary** | Receives all writes (new books, reviews, updates) |
| Node 2 | **Secondary** | Copies every change from the primary, keeping a live backup |
| Node 3 | **Secondary** | Same as node 2 |

**How it works:** when I added a review to *Arrow of God* in Portfolio 4, the primary saved it and recorded the change in its **oplog** (operations log). The two secondaries read the oplog and applied the same change to their own copies, usually within milliseconds.

**Evidence:** screenshot of the cluster's monitoring page showing the three nodes and their roles (`screenshots/01-replica-set-nodes.png`).

## Availability: staying online when a server fails
If the primary server crashes, the two secondaries hold an **election** and one of them becomes the new primary, usually within seconds. The application reconnects automatically, because the connection string (`mongodb+srv://…`) points to the whole cluster, not one server.

For CityReads, this means members can keep searching the catalogue even if one server goes down.

**Limitation:** the "Test Primary Failover" button in Atlas is only available on paid clusters (M10 and above), so I could not trigger a failover on the free tier. On a paid cluster, this test would show a secondary being promoted to primary.

## Sharding: splitting data as the library grows
Replication copies **all** the data to every server. **Sharding** splits the data, so each server (shard) holds only **part** of it. It's needed when there is too much data, or too much traffic, for one server.

**Proposed design if CityReads grew to many branches across Nigeria:**

| Collection | Shard key | Reason |
|---|---|---|
| `catalogue` | `{ isbn: "hashed" }` | Spreads books evenly across shards, so no single server gets overloaded |
| `loans` (if moved to MongoDB) | `{ branch: 1, member_id: 1 }` | Keeps each branch's loans together, so Lagos queries stay on the Lagos shard |

**Zone sharding:** Lagos, Abuja and Kano branch data could be placed on servers in or near those regions, so each branch reads from a nearby server (lower latency) and Nigerian data stays local (data-residency rules under the NDPA 2023).

**Limitation:** sharding needs a dedicated cluster (M30 or above in Atlas). For a single library with thousands of books, one replica set is enough, so sharding is presented here as a design for future growth.

## Consistency: the trade-offs
In a distributed database, the copies are not always perfectly in step. There's a small delay while secondaries catch up with the primary.

| Setting | Option | Effect | CityReads use |
|---|---|---|---|
| **Write concern** | `w: 1` | Confirmed once the primary saves it. Fast, but could be lost if the primary crashes immediately. | Not used for important data |
| | `w: "majority"` (Atlas default) | Confirmed only once 2 of 3 nodes have it. Safe even if one node fails. | Reviews and catalogue updates |
| **Read preference** | `primary` (default) | Always read the latest data | Checking if a copy is available to borrow |
| | `secondaryPreferred` | Read from a copy. Lighter load on the primary, but may be milliseconds out of date. | Browsing the catalogue and reading reviews |

### The CAP theorem
When a network problem splits the servers apart (a **Partition**), a distributed system has to choose between:
- **Consistency:** every read gets the latest data, or an error, and
- **Availability:** every read gets an answer, even if slightly out of date.

| Data | Priority | Reason |
|---|---|---|
| Loans and stock counts (PostgreSQL) | **Consistency** | Lending the last copy twice (Portfolio 3) is unacceptable. Better to refuse than be wrong. |
| Catalogue and reviews (MongoDB) | **Availability** | A review that appears a second late does no harm. Members should always be able to search. |

This matches the design from Portfolio 4: strict data in PostgreSQL, flexible high-read data in MongoDB.

## SQL vs NoSQL in a distributed setting
| | PostgreSQL | MongoDB Atlas |
|---|---|---|
| Replication | Streaming replication to read replicas (set up manually or through a cloud service) | Built in (replica set by default) |
| Automatic failover | Needs extra tools (e.g. Patroni) or a managed cloud service | Built in (automatic election) |
| Sharding | Not built in (needs extensions such as Citus) | Built in |
| Best for CityReads | Loans, fines, stock (strong consistency) | Catalogue, reviews (scale and availability) |

## Evidence (screenshots folder)
| File | Shows |
|---|---|
| `01-replica-set-nodes.png` | The 3 nodes with Primary and Secondary roles |
| `02-cluster-config.png` | Tier, cloud provider, region, MongoDB version |
| `03-network-access.png` | IP access list (security) |
| `04-database-access.png` | Database user (with the password hidden) |
| `05-data-in-cloud.png` | `cityreads.catalogue` with 8 documents in the Atlas Data Explorer |

**Security note:** the connection string and password are **not** stored in this repository.
