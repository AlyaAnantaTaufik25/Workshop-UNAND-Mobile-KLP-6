/// Model data respon health check server
class HealthDatabaseInfo {
  final String status;
  final String message;
  final String? host;
  final dynamic port;
  final String? database;

  const HealthDatabaseInfo({
    required this.status,
    required this.message,
    this.host,
    this.port,
    this.database,
  });

  factory HealthDatabaseInfo.fromJson(Map<String, dynamic> json) {
    return HealthDatabaseInfo(
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      host: json['host'] as String?,
      port: json['port'],
      database: json['database'] as String?,
    );
  }
}

class HealthData {
  final String app;
  final String version;
  final String status;
  final String environment;
  final String timestamp;
  final int uptimeSeconds;
  final HealthDatabaseInfo? database;

  const HealthData({
    required this.app,
    required this.version,
    required this.status,
    required this.environment,
    required this.timestamp,
    required this.uptimeSeconds,
    this.database,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      app: json['app'] as String? ?? 'SIM Workshop UNAND API',
      version: json['version'] as String? ?? '1.0.0',
      status: json['status'] as String? ?? 'unknown',
      environment: json['environment'] as String? ?? 'development',
      timestamp: json['timestamp'] as String? ?? '',
      uptimeSeconds: json['uptimeSeconds'] as int? ?? 0,
      database: json['database'] is Map<String, dynamic>
          ? HealthDatabaseInfo.fromJson(json['database'] as Map<String, dynamic>)
          : null,
    );
  }
}

