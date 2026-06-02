/// Sort order for Radio Browser station queries (per ADR-0027).
///
/// Popular sections reuse `/json/stations/search` with `order=clickcount`
/// (top clicked) or `order=votes` (top voted) instead of the dedicated
/// `/json/stations/topclick`/`topvote` endpoints.
enum StationSort {
  /// Order by total click count.
  clickCount('clickcount'),

  /// Order by user votes.
  votes('votes');

  const StationSort(this.apiValue);

  /// The Radio Browser `order` query parameter value.
  final String apiValue;
}
