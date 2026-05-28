class Shoe {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final bool isNew;
  final double? oldPrice;

  const Shoe({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
    required this.category,
    this.isNew = false,
    this.oldPrice,
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }
}
