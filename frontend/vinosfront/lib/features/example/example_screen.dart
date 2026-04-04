import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dioClient = ref.read(dioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Test Dio")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final response = await dioClient.dio.get(
                'https://jsonplaceholder.typicode.com/posts',
              );
              print(response.data);
            } catch (e) {
              print("Error: $e");
            }
          },
          child: const Text("Test Request"),
        ),
      ),
    );
  }
}