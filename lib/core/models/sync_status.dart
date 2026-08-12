enum SyncStatus {
  synced('synced'),
  pending('pending'),
  syncing('syncing'),
  error('error');

  final String dbValue;

  const SyncStatus(this.dbValue);

  static SyncStatus fromDatabase(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => SyncStatus.synced,
    );
  }
}
