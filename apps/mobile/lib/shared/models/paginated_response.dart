/// Generic paginated API response wrapper.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;

  bool get hasMore => page * pageSize < total;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) mapItem,
  ) {
    final rawItems = json['items'] ?? json['data'] ?? const [];
    final list = rawItems is List ? rawItems : const [];
    return PaginatedResponse<T>(
      items: list
          .whereType<Map<String, dynamic>>()
          .map(mapItem)
          .toList(growable: false),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? list.length,
      total: (json['total'] as num?)?.toInt() ?? list.length,
    );
  }
}
