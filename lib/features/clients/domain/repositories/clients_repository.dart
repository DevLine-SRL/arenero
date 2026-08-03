import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../entities/client.dart';

/// Contrato completo del módulo de clientes, incluidas las operaciones que
/// todavía no tienen interfaz de usuario. Se acuerda una sola vez para que
/// las tareas de la historia #22 avancen sobre archivos disjuntos.
abstract class ClientsRepository {
  /// Tarea #37. Con `query` vacío devuelve todos los clientes activos.
  Future<Either<Failure, List<Client>>> searchClients({
    required String query,
    bool includeInactive = false,
  });

  /// Tarea #36.
  Future<Either<Failure, Client>> createClient({
    required String name,
    required Ci ci,
    String? phone,
  });

  /// Tarea #40. Comprobación previa para avisar al usuario mientras escribe.
  ///
  /// No es la garantía de unicidad: entre esta consulta y el alta puede
  /// entrar otro registro. La garantía es la restricción `clients_ci_unique`,
  /// y [createClient] traduce su violación a un [ValidationFailure].
  Future<Either<Failure, bool>> existsByCi(Ci ci);

  /// Tarea #38.
  Future<Either<Failure, Client>> updateClient({
    required String id,
    required String name,
    required Ci ci,
    String? phone,
  });

  /// Tarea #39.
  Future<Either<Failure, Unit>> setActive(String id, bool active);
}
