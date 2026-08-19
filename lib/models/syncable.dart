/// Interface required of items stored in a `SyncedStore`.
abstract class Syncable {
  String get id;

  Map<String, dynamic> toJson();
}
