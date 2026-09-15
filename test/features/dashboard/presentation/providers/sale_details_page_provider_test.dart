import 'package:arenero/features/dashboard/presentation/providers/reports_providers.dart';
import 'package:arenero/features/dashboard/presentation/providers/sale_details_page_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/report_builders.dart';
import '../../../../support/fakes/fake_reports_repository.dart';

void main() {
  group('SaleDetailsRequest equality', () {
    test('treats requests with the same parameters as equal', () {
      final request = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
        clientId: 'client-1',
        page: 2,
      );

      final same = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
        clientId: 'client-1',
        page: 2,
      );

      expect(request, same);
      expect(request.hashCode, same.hashCode);
    });

    test('distinguishes requests that differ in any parameter', () {
      final request = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
      );

      final otherPage = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
        page: 1,
      );
      final otherSearch = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
        search: 'arena',
      );

      expect(request, isNot(otherPage));
      expect(request, isNot(otherSearch));
    });
  });

  group('saleDetailsPageProvider', () {
    test('returns the page of sale details', () async {
      final repository = FakeReportsRepository();
      repository.saleDetailsResult = Right(buildSaleDetailsPage(totalCount: 2));
      final container = ProviderContainer(
        overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final request = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
        clientId: 'client-1',
      );

      final page = await container.read(
        saleDetailsPageProvider(request).future,
      );

      expect(repository.saleDetailsCallCount, 1);
      expect(page.totalCount, 2);
    });

    test('caches the result for the same request', () async {
      final repository = FakeReportsRepository();
      final container = ProviderContainer(
        overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final request = SaleDetailsRequest(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
        clientId: 'client-1',
      );

      await container.read(saleDetailsPageProvider(request).future);
      await container.read(saleDetailsPageProvider(request).future);

      expect(repository.saleDetailsCallCount, 1);
    });
  });
}
