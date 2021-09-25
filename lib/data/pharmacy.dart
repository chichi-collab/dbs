class Pharmacy {
  String? title;
  String? contact;
  bool? is_active;
  Map? location;
  int? created_at;
  String? id;

  Pharmacy({
    this.contact,
    this.is_active = false,
    this.title,
    this.location,
    this.id,
    this.created_at,
  });

  Pharmacy.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        contact = json['contact'],
        is_active = json['is_active'],
        id = json['id'],
        location = json['location'] as Map<String, dynamic>?,
        created_at = json['created_at'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'contact': contact,
        'is_active': is_active,
        'id': id,
        'location': location,
      };
}
