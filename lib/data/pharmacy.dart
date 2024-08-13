class Pharmacy {
  String? title;
  String? contact;
  bool? isActive;
  Map? location;
  int? createdAt;
  String? id;

  Pharmacy({
    this.contact,
    this.isActive = false,
    this.title,
    this.location,
    this.id,
    this.createdAt,
  });

  Pharmacy.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        contact = json['contact'],
        isActive = json['is_active'],
        id = json['id'],
        location = json['location'] as Map<String, dynamic>?,
        createdAt = json['created_at'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'contact': contact,
        'is_active': isActive,
        'id': id,
        'location': location,
      };
}
