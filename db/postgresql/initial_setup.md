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

# Tuning for predominantly WRITE workload 
## Hardware
- [ ] Use RAID 1+0 instead of RAID 5 or 6.
- [ ] RAID 10 has a much better performance for heavy writes.
- [ ] It's better to store transaction logs (`pg_xlog`) on a separate hard disk.
- [ ] Use SSD hard disks with write-back cache (WBC), which significantly increases write performance.

## PostgreSQL server setting
- [ ] Make sure your SSDs can persist cached data on power failure.
- [ ] fsync (use it only as a most last resort)
- [ ] disable `synchronous_commit`.
- [ ] `commit_delay` - change this setting to non-zero can improve group commit throughput by allowing a larger number of transactions to commit via a single WAL flush.
- [ ] Combining `synchronous_commit` and `commit_delay` both will reduce the effect of enabled fsync, and a hardware crash won't cause data to be corrupted.
- [ ] In PostgreSQL releases prior to 9.3, `commit_delay` behaved differently and was much less effective.
- [ ] Increasing `max_wal_size` causes a performance gain special in heavy write loads. Setting this value very high causes a slow recovery in crash scenarios.
- [ ] `wal_buffers` - disabled by default. Increasing this value helps a busy server with several concurrent clients. It's good to select a size around 3% of shard_buffers but not less than 64 KB. If your system has as good reserve in memory, set it to the maximum, that is 16 MB.
- [ ] `maintenece_work_mem` doesn't directly affect the performance of data insertion, but it increases the performance of creating and maintaining indexes.
- [ ] It aceptable to disable several other settings to increase performance, for example, logging and logging collection can increase performance if you're logging data heavily. Auto-vacuum can be disabled on bulk-load scenarios.

## During bulk load
- [ ] Disable triggers, indexes, and foreign keys on the table that you need to copy.
- [ ] ...or use an UNLOGGED table and then convert it into a logged table.
- [ ]  Increase the batch size of each transaction.
- [ ]  Use the `COPY` command. The JDBC driver, `CopyManager`, can be used for this purpose
- [ ]  Use prepared statements. Prepared statements are faster to execute since the statements are precompiled on the PostgreSQL side.
- [ ]  Use external tool `pg_bulkload`, which is quite fast.
- [ ]  Starting from PostgreSQL 9.3, you can use `COPY` with the `FREEZE` option, which is used often for initial data loading. The FREEZE option violates the MVCC concept in PostgreSQL, which means the data is immediately visible to other sessions after it's loaded.

### Increasing the batch size of each transaction
* It will decrease the delay caused by `synchronous_commit`
* It will preserve transaction IDs; thus...
* ... less vacuum will be required to prevent transaction-ID wraparound
