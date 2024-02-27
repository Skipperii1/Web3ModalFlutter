import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class ApproveTransactionPage extends StatefulWidget {
  const ApproveTransactionPage()
      : super(key: KeyConstants.approveTransactionPage);

  @override
  State<ApproveTransactionPage> createState() => _ApproveTransactionPageState();
}

class _ApproveTransactionPageState extends State<ApproveTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Web3ModalNavbar(
      title: 'Approve Transaction',
      noClose: true,
      safeAreaLeft: true,
      safeAreaRight: true,
      body: SafeArea(
        child: magicService.instance.webview,
      ),
    );
  }
}