# General settings
## Memory
- [ ]  `shared_buffers` - The amount of memory the database server uses for quick access to data. It's recommended to set it to around 25% of the total memory.
- [ ]  `work_mem` - for CPU-bound operations, it's important to increase this value.
- [ ]  `max_connections` - limiting this setting allow to get more free space in `work_mem`.

# Disk
- [ ] `fsync` setting forces each transaction to be written to the hard disk after each commit.
- [ ] `max_wal_size` of a small value might lead to a performance penalty in write-heavy systems; on the other hand, increasing the max_wal_size setting to a high value will increase recovery time.
- [ ] `random_page_cost`, to favor an _Index Scan_ over _Seq scans_. Set this value to 3 in high-end SAN/NAS technologies; set of 1.5 to 2.5 for SSD. Random access to mechanical disk storage is 4.0 if majority of random accesses to disk, such as indexed reads, are in cache. If random accesses to disk lower then 90% in cache, it's need to increase `random_page_cost`.
- [ ]  In a heavily-cached database it should lower `random_page_cost` and `seq_page_cost` relative to the CPU parameters, since the cost of fetching a page already in RAM is much smaller than it would normally be.

# Planner-related
- [ ] `effective_cache_size`.

# TODO:
- [ ] set up logging, checkpoint, WAL settings, and vacuum settings.

# Tuning for write:
- [ ] Use RAID 1+0 instead of RAID 5 or 6.
- [ ] RAID 10 has a much better performance for heavy writes.
- [ ] It's better to store transaction logs (`pg_xlog`) on a separate hard disk.
- [ ] Use SSD hard disks with write-back cache (WBC), which significantly increases write performance.
- [ ] Make sure your SSDs can persist cached data on power failure.
- [ ] fsync
- [ ] disable `synchronous_commit` and commit_delay
