import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/local/local_genres_data_source.dart';
import 'package:radio_app/data/datasources/remote/remote_genres_data_source.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';

/// [GenresRepository] that serves genres network-first with a Hive cache
/// fallback for offline access (per ADR-0013 / `API_SPEC.md` §5.4).
class GenresRepositoryImpl implements GenresRepository {
  /// Creates the repository over remote and local genre data sources.
  GenresRepositoryImpl(this._remote, this._local);

  // ignore: unused_field
  final RemoteGenresDataSource _remote;
  // ignore: unused_field
  final LocalGenresDataSource _local;

  @override
  Future<Result<List<Genre>, Failure>> getGenres({int limit = 50}) {
    throw UnimplementedError();
  }
}
