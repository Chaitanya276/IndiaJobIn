// To parse this JSON data, do
//
//     final governmentJobList = governmentJobListFromJson(jsonString);

import 'dart:convert';

List<GovernmentJobList> governmentJobListFromJson(String str) =>
    List<GovernmentJobList>.from(
        json.decode(str).map((x) => GovernmentJobList.fromJson(x)));

String governmentJobListToJson(List<GovernmentJobList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GovernmentJobList {
  GovernmentJobList({
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

  factory GovernmentJobList.fromJson(Map<String, dynamic> json) =>
      GovernmentJobList(
        id: json["id"],
        description: json["description"],
        sector: json["sector"],
        domain: json["domain"],
        validTill: json["valid_till"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        company: json["company"],
        hr: json["hr"],
        role: json["role"],
        confirm: json["confirm"],
        salary: json["salary"],
        jobLink: json["job_link"],
        isActive: json["is_active"],
      );

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
