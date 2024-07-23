import 'package:intl_phone_field/phone_number.dart';

class PhoneInfo {
  String? countryISOCode;
  String? countryCode;
  String? number;

  PhoneInfo({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
  });

  PhoneInfo.fromPhoneNumber(PhoneNumber pnum) {
    countryISOCode = pnum.countryISOCode;
    countryCode = pnum.countryCode;
    number = pnum.number;
  }

  PhoneInfo.fromJson(Map<String, dynamic> json) {
    try {
      countryISOCode = json['countryISOCode'] as String?;
      countryCode = json['countryCode'] as String?;
      number = json['number'] as String?;
    } catch (e) {
      print('Failed to parse PhoneInfo JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'countryISOCode': countryISOCode,
      'countryCode': countryCode,
      'number': number,
    };
  }

  String getjustNumber(){
    return "$countryCode$number";
  }
}
