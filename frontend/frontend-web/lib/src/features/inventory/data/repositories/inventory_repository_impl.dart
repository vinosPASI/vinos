import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/authenticated_dio.dart';
import '../../domain/entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();
  Future<Map<String, dynamic>> getInventoryItemDetail(String id);
}

class InventoryRepositoryImpl implements InventoryRepository {
  final Dio _dio;

  InventoryRepositoryImpl(this._dio);

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      final response = await _dio.post(
        '/stuko.api.v1.inventory.InventoryService/ListItems',
        data: {},
      );
      
      final List<dynamic> data = response.data['items'] ?? [];
      return data.map<InventoryItem>((item) => InventoryItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error al obtener el inventario: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryItemDetail(String id) async {
    try {
      final response = await _dio.post(
        '/stuko.api.v1.inventory.InventoryService/GetItemDetail',
        data: {'id': id},
      );
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener detalles del item: $e');
    }
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return InventoryRepositoryImpl(dio);
});

final inventoryListProvider = FutureProvider<List<InventoryItem>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryItems();
});
