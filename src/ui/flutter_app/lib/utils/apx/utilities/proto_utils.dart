// import 'package:dealer/protocols/dreammatrix/common.pb.dart';
// import 'package:protobuf/protobuf.dart' as $pb;
// import 'package:protobuf/protobuf.dart';

// class RpcResult<T extends $pb.GeneratedMessage> {
//   final bool isSuccessful;
//   final String errorMessage;
//   final T? payload;

//   RpcResult({this.isSuccessful = true, this.errorMessage = '', this.payload});
//   RpcResult.fromMessage({required ResponseMessage message, required T Function(List<int>, [ExtensionRegistry]) creator})
//       : this(
//           isSuccessful: message.isSuccessful,
//           errorMessage: message.error.value,
//           payload: creator(message.payload),
//         );
// }
