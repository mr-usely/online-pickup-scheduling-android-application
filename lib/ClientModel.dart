/// ClientModel.dart
import 'dart:convert';

Clients clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Clients.fromMap(jsonData);
}

String clientToJson(Clients data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Clients {
  int id;
  String farmerNo;
  String name;
  String pickupPoint;
  int wrapper;
  int nonWrapper;
  int recID;
  String remarks;
  String createdBy;
  DateTime date;
  DateTime dateCancelled;
  DateTime dateBatched;

  Clients(
      {this.id,
      this.farmerNo,
      this.name,
      this.pickupPoint,
      this.wrapper,
      this.nonWrapper,
      this.recID,
      this.remarks,
      this.date,
      this.createdBy,
      this.dateCancelled,
      this.dateBatched});

  factory Clients.fromMap(Map<String, dynamic> json) => new Clients(
      id: json["id"],
      farmerNo: json["farmerNo"],
      name: json['Name'],
      pickupPoint: json["pickupPoint"],
      wrapper: json["wrapper"],
      nonWrapper: json["nonWrapper"],
      recID: json["RecID"],
      remarks: json["Remarks"],
      createdBy: json['CreatedBy'],
      dateBatched: json['BatchedDate'],
      date: json['RecDate'],
      dateCancelled: json['DateCancelled']);

  Map<String, dynamic> toMap() => {
        "id": id,
        "farmerNo": farmerNo,
        'Name': name,
        "pickupPoint": pickupPoint,
        "wrapper": wrapper,
        "nonWrapper": nonWrapper,
        "RecID": recID,
        "CreatedBy": createdBy,
        "Remarks": remarks,
        "BatchedDate": dateBatched,
        "RecDate": date,
        "DateCancelled": dateCancelled
      };
}
