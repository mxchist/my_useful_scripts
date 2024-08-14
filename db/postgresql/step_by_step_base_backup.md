# The source of this script is Mastering Postgersql 15 - Fifth edition, by Hans-Jürgen Schönig

## 1. Optimize the transaction log
- Set up chekpoint frequency.
  - checkpoint_timeout
  - min_wal_size
  - max_wal_size
- If there is a copy-on-write (COW) filesystem such as btrfs, set up the `wal_recycle`

## 2. Configure for archiving of the transaction logs
- Set up `wal_level`         used to be "hot_standby" in older versions
- Set up `max_wal_senders`   at least 2, better at least 2
- Enable `archive_mode`
- Create folder for the archives using `mkdir`
- Change up owner of the created folder using `chown` to user `postgres`
- Set up `archive_command`
  - optionally: set up `archive_library`
- Add in `pg_hba` row for the replication
- Create the base backup
- 


Useful system views:
- pg_stat_progress_basebackup
- pg_stat_archiver

##3. Replaying the transaction log
- Set up `restore_command`
- Set up `recovery_target_time`
  - As alternative of `recovery_target_time`, it's can to use `recovery_target_action`. The source for `recovery_target_action` is function `pg_create_restore_point`.
 
  - 





