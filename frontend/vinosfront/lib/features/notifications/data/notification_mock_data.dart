import 'package:flutter/material.dart';
import '../domain/notification_model.dart';

// Datos de prueba para desarrollo.
class NotificationMockData {
  NotificationMockData._();

  static const List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Nueva oferta disponible',
      description: 'El Malbec Reserva 2022 tiene un 15 % de descuento esta semana.',
      time: 'Ahora',
      icon: Icons.local_offer_outlined,
      isRead: false,
    ),
    NotificationModel(
      title: 'Tu pedido fue enviado',
      description: 'Tu caja de vinos está en camino. Llegará en 2–3 días hábiles.',
      time: '1h',
      icon: Icons.local_shipping_outlined,
      isRead: false,
    ),
    NotificationModel(
      title: 'Reseña aprobada',
      description: 'Tu reseña del Torrontés Clásico 2021 ya es visible en la tienda.',
      time: '3h',
      icon: Icons.rate_review_outlined,
      isRead: true,
    ),
    NotificationModel(
      title: 'Nuevo vino en stock',
      description: 'El Cabernet Franc Barrel Select 2020 acaba de llegar al inventario.',
      time: 'Ayer',
      icon: Icons.wine_bar_outlined,
      isRead: true,
    ),
    NotificationModel(
      title: 'Recordatorio de maridaje',
      description: 'Prueba el Chardonnay Roble con quesos maduros esta noche.',
      time: 'Ayer',
      icon: Icons.restaurant_outlined,
      isRead: true,
    ),
  ];
}