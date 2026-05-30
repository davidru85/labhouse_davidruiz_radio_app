part of 'failure.dart';

/// Sealed class grouping all storage-related domain failures.
sealed class StorageFailure extends Failure {
  /// Creates a storage failure with an optional message.
  const StorageFailure([super.message]);
}

/// Failure representing a database read/write I/O corruption or issue.
final class StorageReadWriteFailure extends StorageFailure {
  /// Creates a [StorageReadWriteFailure] with an optional message.
  const StorageReadWriteFailure([super.message]);

  @override
  String get localizationKey => 'error_storage_io';
}

/// Failure representing an issue during local/remote favorites synchronization.
final class FavoritesSyncFailure extends StorageFailure {
  /// Creates a [FavoritesSyncFailure] with an optional message.
  const FavoritesSyncFailure([super.message]);

  @override
  String get localizationKey => 'error_favorites_sync';
}
