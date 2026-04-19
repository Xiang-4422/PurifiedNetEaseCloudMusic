class DatabaseCollectionSchema {
  const DatabaseCollectionSchema({
    required this.name,
    required this.version,
    required this.description,
  });

  final String name;
  final int version;
  final String description;
}
