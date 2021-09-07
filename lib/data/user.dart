class UserModel {
  String? name;
  String? email;
  bool is_active;
  String? digital_address;
  List<String>? roles;
  int? created_at;
  String? id;
  List<String>? tokens;
  String? type;

  UserModel(
      {this.email,
      this.is_active = false,
      this.name,
      this.type,
      this.digital_address,
      this.id,
      this.tokens,
      this.created_at,
      this.roles});

  UserModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        is_active = json['is_active'],
        type = json['type'],
        id = json['id'],
        tokens = (json['tokens'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        digital_address = json['digital_address'],
        roles =
            (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
        created_at = json['created_at'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'is_active': is_active,
        'type': type,
        'id': id,
        'tokens': tokens,
        'digital_address': digital_address,
        'roles': roles,
        'created_at': created_at,
      };
}
