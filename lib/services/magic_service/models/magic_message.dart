import 'package:web3modal_flutter/web3modal_flutter.dart';

class MagicMessage {
  String type;
  dynamic payload;
  String? rt;
  String? jwt;
  String? action;

  MagicMessage({
    required this.type,
    this.payload,
    this.rt,
    this.jwt,
    this.action,
  });

  factory MagicMessage.fromJson(Map<String, dynamic> json) {
    return MagicMessage(
      type: json['type'],
      rt: json['rt'],
      jwt: json['jwt'],
      action: json['action'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {'type': type};
    if ((payload ?? '').isNotEmpty) {
      params['payload'] = payload;
    }
    if ((rt ?? '').isNotEmpty) {
      params['rt'] = rt;
    }
    if ((jwt ?? '').isNotEmpty) {
      params['jwt'] = jwt;
    }
    if ((action ?? '').isNotEmpty) {
      params['action'] = action;
    }

    return params;
  }

  // @w3m-frame events
  bool get syncThemeSuccess => type == '@w3m-frame/SYNC_THEME_SUCCESS';
  bool get syncDataSuccess => type == '@w3m-frame/SYNC_DAPP_DATA_SUCCESS';
  bool get connectEmailSuccess => type == '@w3m-frame/CONNECT_EMAIL_SUCCESS';
  bool get connectEmailError => type == '@w3m-frame/CONNECT_EMAIL_ERROR';
  bool get isConnectSuccess => type == '@w3m-frame/IS_CONNECTED_SUCCESS';
  bool get isConnectError => type == '@w3m-frame/IS_CONNECTED_ERROR';
  bool get connectOtpSuccess => type == '@w3m-frame/CONNECT_OTP_SUCCESS';
  bool get connectOtpError => type == '@w3m-frame/CONNECT_OTP_ERROR';
  bool get getUserSuccess => type == '@w3m-frame/GET_USER_SUCCESS';
  bool get getUserError => type == '@w3m-frame/GET_USER_ERROR';
  bool get sessionUpdate => type == '@w3m-frame/SESSION_UPDATE';
  bool get switchNetworkSuccess => type == '@w3m-frame/SWITCH_NETWORK_SUCCESS';
  bool get switchNetworkError => type == '@w3m-frame/SWITCH_NETWORK_ERROR';
  bool get rpcRequestSuccess => type == '@w3m-frame/RPC_REQUEST_SUCCESS';
  bool get rpcRequestError => type == '@w3m-frame/RPC_REQUEST_ERROR';
}

// @w3m-app events
class IsConnected extends MagicMessage {
  IsConnected() : super(type: '@w3m-app/IS_CONNECTED');

  @override
  String toString() => '{type: "${super.type}"}';
}

class SwitchNetwork extends MagicMessage {
  final String chainId;
  SwitchNetwork({
    required this.chainId,
  }) : super(type: '@w3m-app/SWITCH_NETWORK');

  @override
  String toString() => '{type:\'${super.type}\',payload:{chainId:$chainId}}';
}

class ConnectEmail extends MagicMessage {
  final String email;
  ConnectEmail({required this.email}) : super(type: '@w3m-app/CONNECT_EMAIL');

  @override
  String toString() => '{type:\'${super.type}\',payload:{email:\'$email\'}}';
}

class ConnectDevice extends MagicMessage {
  ConnectDevice() : super(type: '@w3m-app/CONNECT_DEVICE');

  @override
  String toString() => '{type: "${super.type}"}';
}

class ConnectOtp extends MagicMessage {
  final String otp;
  ConnectOtp({required this.otp}) : super(type: '@w3m-app/CONNECT_OTP');

  @override
  String toString() => '{type:\'${super.type}\',payload:{otp:\'$otp\'}}';
}

class GetUser extends MagicMessage {
  final String? chainId;
  GetUser({this.chainId}) : super(type: '@w3m-app/GET_USER');

  @override
  String toString() {
    if ((chainId ?? '').isNotEmpty) {
      return '{type:\'${super.type}\',payload:{chainId:$chainId}}';
    }
    return '{type:\'${super.type}\'}';
  }
}

class SignOut extends MagicMessage {
  SignOut() : super(type: '@w3m-app/SIGN_OUT');

  @override
  String toString() => '{type: "${super.type}"}';
}

class GetChainId extends MagicMessage {
  GetChainId() : super(type: '@w3m-app/GET_CHAIN_ID');

  @override
  String toString() => '{type: "${super.type}"}';
}

class RpcRequest extends MagicMessage {
  final String method;
  final List<dynamic> params;

  RpcRequest({
    required this.method,
    required this.params,
  }) : super(type: '@w3m-app/RPC_REQUEST');

  @override
  String toString() {
    final m = 'method:\'$method\'';
    final p = params.map((i) => '\'$i\'').toList().join(',');
    return '{type:\'${super.type}\',payload:{$m,params:[$p]}}';
  }
}

class UpdateEmail extends MagicMessage {
  UpdateEmail() : super(type: '@w3m-app/UPDATE_EMAIL');

  @override
  String toString() => '{type: "${super.type}"}';
}
// readonly APP_AWAIT_UPDATE_EMAIL: "@w3m-app/AWAIT_UPDATE_EMAIL";

class SyncTheme extends MagicMessage {
  final String mode;
  SyncTheme({this.mode = 'light'}) : super(type: '@w3m-app/SYNC_THEME');

  @override
  String toString() {
    final tm = 'themeMode:\'$mode\'';
    return '{type:\'${super.type}\',payload:{$tm}}';
  }
}

class SyncAppData extends MagicMessage {
  SyncAppData({
    required this.metadata,
    required this.sdkVersion,
    required this.projectId,
  }) : super(type: '@w3m-app/SYNC_DAPP_DATA');

  final PairingMetadata metadata;
  final String sdkVersion;
  final String projectId;

  @override
  String toString() {
    final v = 'verified: true';
    final p1 = 'projectId:\'$projectId\'';
    final p2 = 'sdkVersion:\'$sdkVersion\'';
    final m1 = 'name:\'${metadata.name}\'';
    final m2 = 'description:\'${metadata.description}\'';
    final m3 = 'url:\'${metadata.url}\'';
    final m4 = 'icons:["${metadata.icons.first}"]';
    final p3 = 'metadata:{$m1,$m2,$m3,$m4}';
    final p = 'payload:{$v,$p1,$p2,$p3}';
    return '{type:\'${super.type}\',$p}';
  }
}
