class OrderItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String storeId;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.storeId,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      storeId: map['storeId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'storeId': storeId,
    };
  }
}
