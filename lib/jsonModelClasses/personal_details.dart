// To parse this JSON data, do
//
//     final personalDetails = personalDetailsFromJson(jsonString);

import 'dart:convert';

PersonalDetails personalDetailsFromJson(String str) => PersonalDetails.fromJson(json.decode(str));

String personalDetailsToJson(PersonalDetails data) => json.encode(data.toJson());

class PersonalDetails {
    PersonalDetails({
        this.email,
        this.educationalDetails,
        this.skills,
        this.exp,
    });

    String email;
    EducationalDetails educationalDetails;
    List<String> skills;
    String exp;

    factory PersonalDetails.fromJson(Map<String, dynamic> json) => PersonalDetails(
        email: json["email"],
        educationalDetails: EducationalDetails.fromJson(json["educational_details"]),
        skills: List<String>.from(json["skills"].map((x) => x)),
        exp: json["exp"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "educational_details": educationalDetails.toJson(),
        "skills": List<dynamic>.from(skills.map((x) => x)),
        "exp": exp,
    };
}

class EducationalDetails {
    EducationalDetails({
        this.ssc,
        this.hsc,
        this.graduation,
        this.postGraduation,
    });

    Graduation ssc;
    Hsc hsc;
    Graduation graduation;
    Graduation postGraduation;

    factory EducationalDetails.fromJson(Map<String, dynamic> json) => EducationalDetails(
        ssc: Graduation.fromJson(json["ssc"]),
        hsc: Hsc.fromJson(json["hsc"]),
        graduation: Graduation.fromJson(json["graduation"]),
        postGraduation: Graduation.fromJson(json["post_graduation"]),
    );

    Map<String, dynamic> toJson() => {
        "ssc": ssc.toJson(),
        "hsc": hsc.toJson(),
        "graduation": graduation.toJson(),
        "post_graduation": postGraduation.toJson(),
    };
}

class Graduation {
    Graduation({
        this.done,
        this.instituteName,
        this.passingYear,
        this.course,
        this.degree,
    });

    bool done;
    String instituteName;
    int passingYear;
    String course;
    String degree;

    factory Graduation.fromJson(Map<String, dynamic> json) => Graduation(
        done: json["done"],
        instituteName: json["institute_name"],
        passingYear: json["passing_year"],
        course: json["course"],
        degree: json["degree"] == null ? null : json["degree"],
    );

    Map<String, dynamic> toJson() => {
        "done": done,
        "institute_name": instituteName,
        "passing_year": passingYear,
        "course": course,
        "degree": degree == null ? null : degree,
    };
}

class Hsc {
    Hsc({
        this.done,
        this.instituteName,
        this.passingYear,
        this.course,
        this.degree,
    });

    bool done;
    String instituteName;
    String passingYear;
    String course;
    dynamic degree;

    factory Hsc.fromJson(Map<String, dynamic> json) => Hsc(
        done: json["done"],
        instituteName: json["institute_name"],
        passingYear: json["passing_year"],
        course: json["course"],
        degree: json["degree"],
    );

    Map<String, dynamic> toJson() => {
        "done": done,
        "institute_name": instituteName,
        "passing_year": passingYear,
        "course": course,
        "degree": degree,
    };
}
