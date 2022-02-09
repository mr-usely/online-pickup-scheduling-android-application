// class response for handling responses like "{"Result":"VISA_Success"}"
class Responses {
  String result;
  Responses(this.result);

  Responses.fromJson(Map<String, dynamic> json) : result = json['Result'];
  Map<String, dynamic> toJson() => {'Result': result};
}
