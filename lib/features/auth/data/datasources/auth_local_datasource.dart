import 'package:drift/drift.dart';

import '../../../../core/models/app_database.dart';
import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> upsertProfile(User user);

  Future<User?> getProfile(String userId);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase database;

  const AuthLocalDataSourceImpl(this.database);

  @override
  Future<void> upsertProfile(User user) async {
    final now = DateTime.now();
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            id: user.id,
            email: user.email,
            name: Value(user.name),
            role: user.role,
            active: user.active,
            lastSeenAt: Value(user.lastSeenAt),
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => LocalProfilesCompanion(
              email: Value(user.email),
              name: Value(user.name),
              role: Value(user.role),
              active: Value(user.active),
              lastSeenAt: Value(user.lastSeenAt),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  @override
  Future<User?> getProfile(String userId) async {
    final row = await (database.select(
      database.localProfiles,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (row == null) return null;
    return User(
      id: row.id,
      email: row.email,
      name: row.name,
      role: row.role,
      active: row.active,
      lastSeenAt: row.lastSeenAt,
    );
  }
}
