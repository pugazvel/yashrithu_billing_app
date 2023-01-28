
class ItemModel {
  int? index;
  int? code;
  String? name;
  double? price;
  double? quantity;

  ItemModel({this.index, this.code, this.name, this.price, this.quantity});

  ItemModel.fromMap(Map<String, dynamic> map) {
    index = map['index'];
    code = map['code'];
    name = map['name'];
    price = map['price'];
    quantity = map['quantity'];
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'code': code,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'code': code,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  ItemModel.clone(ItemModel source) :
    this.index = source.index,
    this.code = source.code,
    this.name = source.name,
    this.price = source.price,
    this.quantity = source.quantity;
}
