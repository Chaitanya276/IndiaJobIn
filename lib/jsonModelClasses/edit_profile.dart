// To parse this JSON data, do
//
//     final editProfile = editProfileFromJson(jsonString);

import 'dart:convert';

EditProfile editProfileFromJson(String str) => EditProfile.fromJson(json.decode(str));

String editProfileToJson(EditProfile data) => json.encode(data.toJson());

class EditProfile {
    EditProfile({
        this.seekerDetails,
        this.educationalDetails,
        this.seekerSkills,
        this.seekerExp,
    });

    SeekerDetails seekerDetails;
    EducationalDetails educationalDetails;
    List<SeekerSkill> seekerSkills;
    List<SeekerExp> seekerExp;

    factory EditProfile.fromJson(Map<String, dynamic> json) => EditProfile(
        seekerDetails: SeekerDetails.fromJson(json["seeker_details"]),
        educationalDetails: EducationalDetails.fromJson(json["educational_details"]),
        seekerSkills: List<SeekerSkill>.from(json["seeker_skills"].map((x) => SeekerSkill.fromJson(x))),
        seekerExp: List<SeekerExp>.from(json["seeker_exp"].map((x) => SeekerExp.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "seeker_details": seekerDetails.toJson(),
        "educational_details": educationalDetails.toJson(),
        "seeker_skills": List<dynamic>.from(seekerSkills.map((x) => x.toJson())),
        "seeker_exp": List<dynamic>.from(seekerExp.map((x) => x.toJson())),
    };
}

class EducationalDetails {
    EducationalDetails({
        this.ssc,
        this.hsc,
        this.graduation,
        this.postGraduation,
        this.iti,
        this.diploma,
    });

    Diploma ssc;
    Diploma hsc;
    Diploma graduation;
    Diploma postGraduation;
    Diploma iti;
    Diploma diploma;

    factory EducationalDetails.fromJson(Map<String, dynamic> json) => EducationalDetails(
        ssc: Diploma.fromJson(json["ssc"]),
        hsc: Diploma.fromJson(json["hsc"]),
        graduation: Diploma.fromJson(json["graduation"]),
        postGraduation: Diploma.fromJson(json["post_graduation"]),
        iti: Diploma.fromJson(json["iti"]),
        diploma: Diploma.fromJson(json["diploma"]),
    );

    Map<String, dynamic> toJson() => {
        "ssc": ssc.toJson(),
        "hsc": hsc.toJson(),
        "graduation": graduation.toJson(),
        "post_graduation": postGraduation.toJson(),
        "iti": iti.toJson(),
        "diploma": diploma.toJson(),
    };
}

class Diploma {
    Diploma({
        this.id,
        this.eduFields,
        this.instituteName,
        this.passingYear,
        this.course,
        this.marks,
        this.degree,
    });

    String id;
    String eduFields;
    String instituteName;
    String passingYear;
    String course;
    dynamic marks;
    String degree;

    factory Diploma.fromJson(Map<String, dynamic> json) => Diploma(
        id: json["id"],
        eduFields: json["edu_fields"],
        instituteName: json["institute_name"],
        passingYear: json["passing_year"],
        course: json["course"],
        marks: json["marks"],
        degree: json["degree"] == null ? null : json["degree"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "edu_fields": eduFields,
        "institute_name": instituteName,
        "passing_year": passingYear,
        "course": course,
        "marks": marks,
        "degree": degree == null ? null : degree,
    };
}

class SeekerDetails {
    SeekerDetails({
        this.id,
        this.firstname,
        this.lastname,
        this.mobile,
        this.email,
        this.city,
        this.address,
        this.country,
        this.state,
        this.postal,
        this.college,
        this.image,
        this.background,
        this.refferedBy,
        this.validated,
    });

    String id;
    String firstname;
    String lastname;
    String mobile;
    String email;
    String city;
    String address;
    String country;
    String state;
    String postal;
    String college;
    String image;
    String background;
    String refferedBy;
    dynamic validated;

    factory SeekerDetails.fromJson(Map<String, dynamic> json) => SeekerDetails(
        id: json["id"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        mobile: json["mobile"],
        email: json["email"],
        city: json["city"],
        address: json["address"],
        country: json["country"],
        state: json["state"],
        postal: json["postal"],
        college: json["college"],
        image: json["image"],
        background: json["background"],
        refferedBy: json["reffered_by"],
        validated: json["validated"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "mobile": mobile,
        "email": email,
        "city": city,
        "address": address,
        "country": country,
        "state": state,
        "postal": postal,
        "college": college,
        "image": image,
        "background": background,
        "reffered_by": refferedBy,
        "validated": validated,
    };
}

class SeekerExp {
    SeekerExp({
        this.id,
        this.orgName,
        this.desgName,
        this.exp,
        this.industry,
        this.startedFrom,
        this.endTill,
        this.seeker,
    });

    String id;
    String orgName;
    String desgName;
    String exp;
    String industry;
    String startedFrom;
    String endTill;
    String seeker;

    factory SeekerExp.fromJson(Map<String, dynamic> json) => SeekerExp(
        id: json["id"],
        orgName: json["org_name"],
        desgName: json["desg_name"],
        exp: json["exp"],
        industry: json["industry"],
        startedFrom: json["started_from"],
        endTill: json["end_till"],
        seeker: json["seeker"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "org_name": orgName,
        "desg_name": desgName,
        "exp": exp,
        "industry": industry,
        "started_from": startedFrom,
        "end_till": endTill,
        "seeker": seeker,
    };
}

class SeekerSkill {
    SeekerSkill({
        this.id,
        this.skill,
    });

    String id;
    String skill;

    factory SeekerSkill.fromJson(Map<String, dynamic> json) => SeekerSkill(
        id: json["id"],
        skill: json["skill"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "skill": skill,
    };
}
