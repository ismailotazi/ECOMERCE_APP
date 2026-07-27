class OrderItemModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }
}
