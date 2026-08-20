import 'package:dartz/dartz.dart' as dartz;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  const ProductsRepositoryImpl(this.remoteDataSource);

  @override
  Future<dartz.Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return dartz.Right(products);
    } on supabase.PostgrestException {
      return const dartz.Left(
        UnexpectedFailure(message: 'No se pudieron obtener los productos.'),
      );
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(
          message: 'Error inesperado al obtener los productos.',
        ),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) async {
    try {
      await remoteDataSource.createProduct(
        name: name,
        unit: unit,
        unitPrice: unitPrice,
      );
      return const dartz.Right(dartz.unit);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapCreateProductError(e));
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(message: 'No se pudo registrar el producto.'),
      );
    }
  }

  Failure _mapCreateProductError(supabase.PostgrestException e) {
    if (e.code == '23505') {
      return const ValidationFailure(
        message: 'Ya existe un producto registrado con ese nombre.',
        code: 'PRODUCT_DUPLICATE',
      );
    }
    if (e.code == '42501') {
      return const UnauthorizedFailure(
        message: 'No tienes permisos para registrar productos.',
      );
    }
    return UnexpectedFailure(
      message: 'No se pudo registrar el producto.',
      code: e.code,
    );
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateProductName({
    required String id,
    required String name,
  }) async {
    try {
      await remoteDataSource.updateProductName(id: id, name: name);
      return const dartz.Right(dartz.unit);
    } on supabase.PostgrestException catch (e) {
      if (e.code == '23505') {
        return const dartz.Left(
          ValidationFailure(
            message: 'Ya existe un producto registrado con ese nombre.',
            code: 'PRODUCT_DUPLICATE',
          ),
        );
      }
      if (e.code == '42501') {
        return const dartz.Left(
          UnauthorizedFailure(
            message: 'No tienes permisos para modificar productos.',
          ),
        );
      }
      return dartz.Left(
        UnexpectedFailure(
          message: 'No se pudo modificar el producto.',
          code: e.code,
        ),
      );
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(
          message: 'Error inesperado al modificar el producto.',
        ),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) async {
    try {
      await remoteDataSource.updateUnitPrice(
        unitId: unitId,
        unitPrice: unitPrice,
      );
      return const dartz.Right(dartz.unit);
    } on supabase.PostgrestException catch (e) {
      if (e.code == '42501') {
        return const dartz.Left(
          UnauthorizedFailure(
            message: 'No tienes permisos para actualizar precios.',
          ),
        );
      }
      return dartz.Left(
        UnexpectedFailure(
          message: 'No se pudo actualizar el precio.',
          code: e.code,
        ),
      );
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(message: 'Error inesperado al actualizar el precio.'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> setActive(
    String id,
    bool active,
  ) async {
    try {
      await remoteDataSource.setActive(id, active);
      return const dartz.Right(dartz.unit);
    } on supabase.PostgrestException catch (e) {
      if (e.code == '42501') {
        return const dartz.Left(
          UnauthorizedFailure(
            message: 'No tienes permisos para actualizar productos.',
          ),
        );
      }
      return const dartz.Left(
        UnexpectedFailure(
          message: 'No se pudo actualizar el estado del producto.',
        ),
      );
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el estado del producto.',
        ),
      );
    }
  }
}
