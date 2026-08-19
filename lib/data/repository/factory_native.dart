import '../../domain/repository/coupon_repository.dart';
import '../local/database.dart';
import 'drift_coupon_repository.dart';

AppDatabase? _database;

Future<CouponRepository> createCouponRepository() async {
  final db = _database ??= AppDatabase();
  return DriftCouponRepository(db);
}

Future<void> closeCouponRepository() async {
  await _database?.close();
  _database = null;
}
