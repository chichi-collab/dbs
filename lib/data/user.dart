class UserModel {
  String? name;
  String? email;
  bool isActive;
  String? digitalAddress;
  List<String>? roles;
  int? createdAt;
  String? id;
  List<String>? tokens;
  String? type;

  UserModel(
      {this.email,
      this.isActive = false,
      this.name,
      this.type,
      this.digitalAddress,
      this.id,
      this.tokens,
      this.createdAt,
      this.roles});

  UserModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        isActive = json['is_active'],
        type = json['type'],
        id = json['id'],
        tokens = (json['tokens'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        digitalAddress = json['digital_address'],
        roles =
            (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
        createdAt = json['created_at'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'is_active': isActive,
        'type': type,
        'id': id,
        'tokens': tokens,
        'digital_address': digitalAddress,
        'roles': roles,
        'created_at': createdAt,
      };
}
