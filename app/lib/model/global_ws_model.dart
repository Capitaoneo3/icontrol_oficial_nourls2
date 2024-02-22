class GlobalWSModel {
  final dynamic id;
  final dynamic status;
  final dynamic msg;
  final dynamic rows;

  GlobalWSModel({
    required this.id,
    required this.status,
    required this.msg,
    required this.rows,
  });

  // factory GlobalWSModel.fromJson(Map<String, dynamic> json) {
  //   return GlobalWSModel(
  //     status: json['status'],
  //     msg: json['msg'],
  //   );
  // }
  //
  // Map<String, dynamic> toJson() {
  //   return {
  //     'status': status,
  //     'msg': msg,
  //   };
  // }
}
