// Emergency Model
import 'dart:io';

class Emergencymodel {
  final String id;
  final String emergencyType; // Original field from API
  final FastCall? fastcall;
  final Report? report;
  final Msg? msg; // New field to handle the "msg" object
  final User user;
  final String nameUser; // For UI display
  final String gps;
        String Needs;
   bool Status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Emergencymodel({
    required this.id,
    required this.emergencyType,
    this.fastcall,
    this.report,
    this.msg,
    required this.user,
    required this.nameUser,
    required this.gps,
    required this.Needs,
    required this.Status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Emergencymodel.fromJson(Map<String, dynamic> json) {
    return Emergencymodel(
      id: json['_id'],
      emergencyType: json['emergencyType'],
      fastcall: json['fastcall'] != null ? FastCall.fromJson(json['fastcall']) : null,
      report: json['report'] != null ? Report.fromJson(json['report']) : null,
      msg: json['msg'] != null ? Msg.fromJson(json['msg']) : null,
      user: User.fromJson(json['user']),
      nameUser: json['user']['fullName'],
      gps: json['gps'] ?? '',
      Needs: json['Needs'] ?? '',
      Status: json['status'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  
  String get emergencyTypeArabic {
    switch (emergencyType) {
      case 'fastcall':
        return 'اتصال سريع';
      case 'raport':
      case 'report':
        return 'ابلاغ';
      case 'msg':
        return 'رسالة';
      default:
        return emergencyType;
    }
  }
  
  // Helper method to get the content based on emergency type
}

// New model class for the "msg" field
class Msg {
  final String id;
  final String emergencyType;
  final String needs;
  final bool injured;
  final bool inTheSence;
  final DateTime createdAt;
  final DateTime updatedAt;

  Msg({
    required this.id,
    required this.emergencyType,
    required this.needs,
    required this.injured,
    required this.inTheSence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Msg.fromJson(Map<String, dynamic> json) {
    return Msg(
      id: json['_id'],
      emergencyType: json['emergencyType'],
      needs: json['Needs'],
      injured: json['injured']  ?? false,
      inTheSence: json['inTheSence'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Other model classes remain the same
class FastCall {
  final String id;
  final List<String> images;
  final String vocal;
  final String video;
  final DateTime createdAt;
  final DateTime updatedAt;

  FastCall({
    required this.id,
    required this.images,
    required this.vocal,
    required this.video,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FastCall.fromJson(Map<String, dynamic> json) {
    return FastCall(
      id: json['_id'],
      images: json['image'] != null 
          ? List<String>.from(json['image'])
          : [],
      vocal: json['vocal'] ?? '',
      video: json['video'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Report {
  final String id;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class User {
  
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  String image;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
   
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      image: json['image'] ?? '',
    );
  }
}