import 'package:dio/dio.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final Dio _dio;

  InventoryRepositoryImpl(this._dio);

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      final response = await _dio.post(
        '/stuko.api.v1.inventory.InventoryService/ListInventoryItems',
        data: {}, // Vacío si no hay request con parámetros
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Asumiendo que el proto devuelve un key 'items' que es un arreglo
        final List<dynamic> itemsData = data['items'] ?? [];
        return itemsData.map((item) => InventoryItem.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener inventario: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final String message = e.response?.data['message'] ?? e.message;
      throw Exception('Error de red al traer inventario: $message');
    }
  }
}
