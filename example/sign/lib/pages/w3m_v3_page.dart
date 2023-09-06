import 'dart:async';

import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';
import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class W3MV3Page extends StatefulWidget {
  const W3MV3Page({
    super.key,
    required this.web3App,
  });

  final IWeb3App web3App;

  @override
  State<W3MV3Page> createState() => _W3MPageState();
}

class _W3MPageState extends State<W3MV3Page>
    with SingleTickerProviderStateMixin {
  late IW3MService _w3mService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    widget.web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);
    _initializeService();
  }

  Future<bool> _initializeService() async {
    try {
      _w3mService = W3MService(
        web3App: widget.web3App,
        recommendedWalletIds: {
          'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
          '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
        },
      );

      await _w3mService.init();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    widget.web3App.onSessionConnect.unsubscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.unsubscribe(_onWeb3AppDisconnect);
    super.dispose();
  }

  void _onWeb3AppConnect(SessionConnect? args) {
    // If we connect, default to barebones
    setState(() {
      _isConnected = true;
    });
  }

  void _onWeb3AppDisconnect(SessionDelete? args) {
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeService(),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == false) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: WalletConnectModalTheme.getData(context).primary100,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(StringConstants.w3mPageTitleV3),
          ),
          body: _isConnected
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    W3MConnect(service: _w3mService),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: SessionWidget(
                          session: widget.web3App.sessions.getAll().first,
                          web3App: widget.web3App,
                          launchRedirect: () {
                            _w3mService.launchCurrentWallet();
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : W3MNetworkSelect(service: _w3mService),
        );
      },
    );
  }
}
