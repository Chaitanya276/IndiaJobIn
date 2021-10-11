// To parse this JSON data, do
//
//     final jobList = jobListFromJson(jsonString);

import 'dart:convert';

List<PrivateJobList> jobListFromJson(String str) => List<PrivateJobList>.from(
    json.decode(str).map((x) => PrivateJobList.fromJson(x)));

String jobListToJson(List<PrivateJobList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PrivateJobList {
  PrivateJobList({
    this.id,
    this.description,
    this.sector,
    this.domain,
    this.validTill,
    this.city,
    this.state,
    this.country,
    this.company,
    this.hr,
    this.role,
    this.confirm,
    this.salary,
    this.jobLink,
    this.isActive,
  });

  dynamic id;
  dynamic description;
  dynamic sector;
  dynamic domain;
  dynamic validTill;
  dynamic city;
  dynamic state;
  dynamic country;
  dynamic company;
  dynamic hr;
  dynamic role;
  dynamic confirm;
  dynamic salary;
  dynamic jobLink;
  dynamic isActive;

  PrivateJobList.fromJson(Map<String, dynamic> json) {
    // ignore: unused_label
    id:
    // ignore: unnecessary_statements
    json["id"];
    // ignore: unused_label
    description:
    // ignore: unnecessary_statements
    json["description"];
    // ignore: unused_label
    sector:
    // ignore: unnecessary_statements
    json["sector"];
    // ignore: unused_label
    domain:
    // ignore: unnecessary_statements
    json["domain"];
    // ignore: unused_label
    validTill:
    // ignore: unnecessary_statements
    json["valid_till"];
    // ignore: unused_label
    city:
    // ignore: unnecessary_statements
    json["city"];
    // ignore: unused_label
    state:
    // ignore: unnecessary_statements
    json["state"];
    // ignore: unused_label
    country:
    // ignore: unnecessary_statements
    json["country"];
    // ignore: unused_label
    company:
    // ignore: unnecessary_statements
    json["company"];
    // ignore: unused_label
    hr:
    // ignore: unnecessary_statements
    json["hr"];
    // ignore: unused_label
    role:
    // ignore: unnecessary_statements
    json["role"];
    // ignore: unused_label
    confirm:
    // ignore: unnecessary_statements
    json["confirm"];
    // ignore: unused_label
    salary:
    // ignore: unnecessary_statements
    json["salary"];
    // ignore: unused_label
    jobLink:
    // ignore: unnecessary_statements
    json["job_link"];
    // ignore: unused_label
    isActive:
    // ignore: unnecessary_statements
    json["is_active"];
  }

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "description": description,
        "sector": sector,
        "domain": domain,
        "valid_till": validTill,
        "city": city,
        "state": state,
        "country": country,
        "company": company,
        "hr": hr,
        "role": role,
        "confirm": confirm,
        "salary": salary,
        "job_link": jobLink,
        "is_active": isActive,
      };
}
