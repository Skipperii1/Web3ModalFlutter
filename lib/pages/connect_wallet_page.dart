import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/segmented_control.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/download_wallet_item.dart';
import 'package:web3modal_flutter/widgets/avatars/loading_border.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class ConnectWalletPage extends StatefulWidget {
  const ConnectWalletPage()
      : super(key: Web3ModalKeyConstants.connecWalletPageKey);

  @override
  State<ConnectWalletPage> createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends State<ConnectWalletPage>
    with WidgetsBindingObserver {
  IW3MService? _service;
  W3MWalletInfo? _selectedWallet;
  SegmentOption _selectedSegment = SegmentOption.mobile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _service = Web3ModalProvider.of(context).service;
        _selectedWallet = _service?.selectedWallet;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_selectedWallet?.installed == true) {
          _service?.connectSelectedWallet();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final isOpen = _service?.isOpen ?? false;
      if (isOpen && _service?.session != null) {
        _service?.closeModal();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // TODO I don't like this whole widget, must be refactored
  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final webOnlyWallet = service.selectedWalletRedirect?.webOnly == true;
    final mobileOnlyWallet = service.selectedWalletRedirect?.mobileOnly == true;
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final walletName = service.selectedWallet?.listing.name ?? 'Wallet';
    final imageId = service.selectedWallet?.listing.imageId ?? '';
    final imageUrl = explorerService.instance!.getWalletImageUrl(imageId);
    final walletInstalled = _selectedWallet?.installed ?? false;
    final isPortrait = ResponsiveData.isPortrait(context);
    final maxWidth = isPortrait
        ? ResponsiveData.maxWidthOf(context)
        : ResponsiveData.maxHeightOf(context) -
            kNavbarHeight -
            (kPadding16 * 2);
    return Web3ModalNavbar(
      title: walletName,
      onBack: () {
        // TODO check if needed => service.selectWallet(walletData: null);
        widgetStack.instance.pop();
      },
      body: SingleChildScrollView(
        scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kPadding16),
        child: Flex(
          direction: isPortrait ? Axis.vertical : Axis.horizontal,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(dimension: 12.0),
                  Visibility(
                    visible: !webOnlyWallet && !mobileOnlyWallet,
                    child: SegmentedControl(
                      onChange: (option) => setState(() {
                        _selectedSegment = option;
                      }),
                    ),
                  ),
                  const SizedBox.square(dimension: 20.0),
                  LoadingBorder(
                    animate: walletInstalled,
                    child: W3MListAvatar(
                      imageUrl: imageUrl,
                    ),
                  ),
                  const SizedBox.square(dimension: 20.0),
                  Text(
                    'Continue in $walletName',
                    textAlign: TextAlign.center,
                    style: themeData.textStyles.paragraph500.copyWith(
                      color: themeColors.foreground100,
                    ),
                  ),
                  const SizedBox.square(dimension: 8.0),
                  Text(
                    webOnlyWallet || _selectedSegment == SegmentOption.browser
                        ? 'Open and continue in a new browser tab'
                        : 'Accept connection request in the wallet',
                    textAlign: TextAlign.center,
                    style: themeData.textStyles.small500.copyWith(
                      color: themeColors.foreground200,
                    ),
                  ),
                  const SizedBox.square(dimension: kPadding16),
                  Visibility(
                    visible:
                        isPortrait && _selectedSegment != SegmentOption.browser,
                    child: SimpleIconButton(
                      onTap: () => service.connectSelectedWallet(),
                      leftIcon: 'assets/icons/refresh.svg',
                      title: 'Try again',
                      backgroundColor: Colors.transparent,
                      foregroundColor: themeColors.accent100,
                    ),
                  ),
                  Visibility(
                    visible: isPortrait &&
                        (webOnlyWallet ||
                            _selectedSegment == SegmentOption.browser),
                    child: SimpleIconButton(
                      onTap: () => service.connectSelectedWallet(
                        inBrowser: _selectedSegment == SegmentOption.browser,
                      ),
                      leftIcon: 'assets/icons/arrow_top_right.svg',
                      title: 'Open',
                      backgroundColor: Colors.transparent,
                      foregroundColor: themeColors.accent100,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPortrait) const SizedBox.square(dimension: kPadding16),
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPortrait) const SizedBox.square(dimension: kPadding12),
                  Visibility(
                    visible: !isPortrait &&
                        _selectedSegment != SegmentOption.browser,
                    child: SimpleIconButton(
                      onTap: () => service.connectSelectedWallet(),
                      leftIcon: 'assets/icons/refresh.svg',
                      title: 'Try again',
                      backgroundColor: Colors.transparent,
                      foregroundColor: themeColors.accent100,
                    ),
                  ),
                  Visibility(
                    visible: !isPortrait &&
                        (webOnlyWallet ||
                            _selectedSegment == SegmentOption.browser),
                    child: SimpleIconButton(
                      onTap: () => service.connectSelectedWallet(
                        inBrowser: _selectedSegment == SegmentOption.browser,
                      ),
                      leftIcon: 'assets/icons/arrow_top_right.svg',
                      title: 'Open',
                      backgroundColor: Colors.transparent,
                      foregroundColor: themeColors.accent100,
                    ),
                  ),
                  if (!isPortrait) const SizedBox.square(dimension: kPadding8),
                  SimpleIconButton(
                    onTap: () => _copyToClipboard(context),
                    leftIcon: 'assets/icons/copy.svg',
                    title: 'Copy link',
                    backgroundColor: Colors.transparent,
                    foregroundColor: themeColors.foreground200,
                    overlayColor: MaterialStateProperty.all<Color>(
                      themeColors.background200,
                    ),
                    withBorder: false,
                  ),
                  if (!isPortrait) const SizedBox.square(dimension: kPadding8),
                  if (!walletInstalled &&
                      _selectedSegment == SegmentOption.mobile)
                    Column(
                      children: [
                        if (isPortrait)
                          const SizedBox.square(dimension: kPadding16),
                        if (_selectedWallet != null)
                          DownloadWalletItem(
                            walletInfo: _selectedWallet!,
                            webOnly: webOnlyWallet,
                          ),
                        const SizedBox.square(dimension: kPadding16),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final service = Web3ModalProvider.of(context).service;
    await Clipboard.setData(ClipboardData(text: service.wcUri!));
    toastUtils.instance.show(
      ToastMessage(type: ToastType.success, text: 'Link copied'),
    );
  }
}
