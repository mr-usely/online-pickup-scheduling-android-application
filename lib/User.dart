class User {
  final String name;
  final String id;
  final String position;
  final String apiKey;

  User(this.name, this.id, this.position, this.apiKey);

  User.fromJson(Map<String, dynamic> json)
      : name = json['Name'],
        id = json['UserID'],
        position = json['Position'],
        apiKey = json['APIKey'];

  Map<String, dynamic> toJson() => {
        'Name': name,
        'UserID': id,
        'Position': position,
        'APIKey': apiKey,
      };
}
