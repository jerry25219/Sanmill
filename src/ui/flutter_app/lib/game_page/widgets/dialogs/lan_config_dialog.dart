


import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../generated/intl/l10n.dart';
import '../../../shared/database/database.dart';
import '../../../shared/services/logger.dart';
import '../../services/mill.dart';

class LanConfigDialog extends StatefulWidget {
  const LanConfigDialog({super.key});

  @override
  LanConfigDialogState createState() => LanConfigDialogState();
}

class LanConfigDialogState extends State<LanConfigDialog>
    with SingleTickerProviderStateMixin {

  bool isHost = true;


  bool _serverRunning = false;


  bool _isDiscovering = false;


  bool _isConnecting = false;


  bool _discoverySuccess = false;


  int _currentAttempt = 0;


  final int _maxAttempt = 3;


  String? _protocolMismatchMessage;


  late AnimationController _iconController;


  late TextEditingController _ipController;


  late TextEditingController _portController;


  String? _ipError;


  String? _portError;


  Timer? _discoveryTimer;


  int _discoverySeconds = 0;


  late NetworkService _networkService;


  String _hostInfo = "";




  bool _hostPlaysWhite = true;


  String? _selectedIP;


  Future<void> _setupNetworkInterfaces() async {
    try {
      final List<String> ips = await NetworkService.getLocalIpAddresses();

      if (!mounted) {
        return;
      }

      if (ips.isEmpty) {
        logger.e("No network interfaces found");
        return;
      }


      if (ips.length == 1) {
        setState(() {
          _selectedIP = ips.first;
        });
        return;
      }


      setState(() {
        _selectedIP = ips.first;
      });

      if (mounted) {
        _showNetworkInterfaceDialog(ips);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      logger.e("Error getting network interfaces: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error detecting network interfaces: $e"),
        ),
      );
    }
  }


  void _showNetworkInterfaceDialog(List<String> ips) {
    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(S.of(dialogContext).pleaseSelect),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ips.length,
              itemBuilder: (BuildContext itemContext, int index) {
                final String ip = ips[index];
                return RadioListTile<String>(
                  title: Text(ip),
                  value: ip,
                  groupValue: _selectedIP,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedIP = value;
                    });
                    logger.i("Selected network interface: $_selectedIP");
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();


    if (GameController().networkService != null &&
        GameController().networkService!.isHost) {
      _networkService = GameController().networkService!;
      _serverRunning = true;
    } else {
      _networkService = NetworkService();
    }


    _hostPlaysWhite = GameController().lanHostPlaysWhite ?? true;


    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..stop();

    _ipController = TextEditingController(text: "192.168.1.100");
    _portController = TextEditingController(text: "33333");


    _networkService.onDisconnected = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).connectionLostDueToHeartbeatTimeoutPleaseReconnect,
              softWrap: true,
            ),
          ),
        );
      }
    };

    _networkService.onProtocolMismatch = (String message) {
      if (mounted) {
        setState(() {
          _protocolMismatchMessage = message;
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              softWrap: true,
            ),
          ),
        );
      }
    };

    _networkService.onConnectionStatusChanged = (bool isConnected) {
      if (mounted && !isConnected && _serverRunning) {
        setState(() {
          _serverRunning = false;
          _iconController.stop();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).serverIsStopped,
              softWrap: true,
            ),
          ),
        );
      }
    };


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNetworkInterfaces();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _discoveryTimer?.cancel();


    _hostInfo = "";


    if (GameController().networkService == null) {
      _networkService.dispose();
    }
    super.dispose();
  }


  Future<void> _startHosting() async {
    if (!mounted) {
      return;
    }


    final NetworkService? existingService = GameController().networkService;
    if (existingService != null &&
        existingService.isHost &&
        existingService.serverSocket != null) {
      setState(() {
        _serverRunning = true;
      });
      return;
    }


    GameController().networkService = _networkService;
    GameController().lanHostPlaysWhite = _hostPlaysWhite;

    setState(() {
      _serverRunning = true;
    });
    _iconController.repeat();

    final int port = int.tryParse(_portController.text) ?? 33333;
    try {
      await _networkService.startHost(
        port,
        localIpAddress: _selectedIP,
        onClientConnected: (String clientIp, int clientPort) {
          GameController().networkService = _networkService;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S
                      .of(context)
                      .clientConnected(clientIp, clientPort.toString()),
                  softWrap: true,
                ),
              ),
            );
            Navigator.pop(context, true);
          }
        },
      );


      setState(() {
        _hostInfo =
            _selectedIP != null ? "${_selectedIP!}:$port" : "Unknown:$port";
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverRunning = false;
        });
        _iconController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).failedToStartHosting(e.toString()),
              softWrap: true,
            ),
          ),
        );
      }
    }
  }


  Future<void> _stopHosting() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _serverRunning = false;
      _hostInfo = "";
    });
    _iconController.stop();
    _networkService.dispose();
    GameController().networkService = null;


    GameController().headerTipNotifier.showTip(S.of(context).serverIsStopped);
    GameController().headerIconsNotifier.showIcons();


    _networkService = NetworkService();
  }


  Future<void> _startDiscovery() async {
    final S translations = S.of(context);

    if (!mounted) {
      return;
    }

    setState(() {
      _isDiscovering = true;
      _discoverySeconds = 0;
      _discoverySuccess = false;
    });
    _discoveryTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _discoverySeconds++;
        });
      }
    });


    final String? discoveryIp = _selectedIP;


    final String? discovered = await NetworkService.discoverHost(
      localIpAddress: discoveryIp,
    );
    _cancelDiscovery();

    if (!mounted) {
      return;
    }

    if (discovered != null) {
      final List<String> parts = discovered.split(':');
      if (parts.length == 2) {
        setState(() {
          _ipController.text = parts[0];
          _portController.text = parts[1];
          _discoverySuccess = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              translations.hostDiscovered(parts[0], parts[1]),
              softWrap: true,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translations.noHostDiscovered,
            softWrap: true,
          ),
        ),
      );
    }
  }


  void _cancelDiscovery() {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    if (mounted) {
      setState(() {
        _isDiscovering = false;
      });
    }
  }


  Future<void> _onConnect() async {
    if (!mounted) {
      return;
    }

    final RegExp ipRegex = RegExp(
        r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$');
    final bool ipValid = ipRegex.hasMatch(_ipController.text);
    final int? port = int.tryParse(_portController.text);
    final bool portValid = port != null && port > 0 && port <= 65535;

    setState(() {
      _ipError = ipValid ? null : S.of(context).invalidIpAddress;
      _portError = portValid ? null : S.of(context).invalidPort;
    });

    if (!ipValid || !portValid) {
      return;
    }

    setState(() {
      _isConnecting = true;
      _currentAttempt = 0;
      _discoverySuccess = false;
    });

    bool connected = false;
    while (_currentAttempt < _maxAttempt && !connected && mounted) {
      setState(() {
        _currentAttempt++;
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));

      try {
        await _networkService.connectToHost(_ipController.text, port);
        connected = true;
        GameController().networkService = _networkService;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).connectedToHostSuccessfully,
                softWrap: true,
              ),
            ),
          );
          Navigator.pop(context, true);
        }
        return;
      } catch (e) {
        if (_currentAttempt >= _maxAttempt && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).failedToConnect(e.toString()),
                softWrap: true,
              ),
            ),
          );
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DialogThemeData dialogThemeObject = Theme.of(context).dialogTheme;
    final Color baseColor = dialogThemeObject.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    final Size screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: baseColor,
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      content: SizedBox(
        width: screenSize.width * 0.8,
        height: screenSize.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text(
                      S.of(context).localNetworkSettings,
                      style: Theme.of(context).textTheme.titleLarge,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile<bool>(
                            contentPadding: EdgeInsets.zero,
                            value: true,
                            groupValue: isHost,
                            onChanged: (bool? val) {
                              setState(() {
                                isHost = true;
                                _isDiscovering = false;
                                _isConnecting = false;
                                _discoverySuccess = false;
                                _protocolMismatchMessage = null;
                              });
                            },
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: <Widget>[
                                const Icon(FluentIcons.desktop_24_regular,
                                    size: 20),
                                Text(S.of(context).host),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            contentPadding: EdgeInsets.zero,
                            value: false,
                            groupValue: isHost,
                            onChanged: (bool? val) {
                              setState(() {
                                isHost = false;
                                _serverRunning = false;
                                _iconController.stop();
                                _protocolMismatchMessage = null;
                              });
                            },
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: <Widget>[
                                const Icon(
                                    FluentIcons.plug_connected_24_regular,
                                    size: 20),
                                Text(S.of(context).join),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),


                    if (isHost)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: <Widget>[
                              if (_serverRunning)
                                RotationTransition(
                                  turns: _iconController,
                                  child: Icon(
                                    FluentIcons.arrow_clockwise_24_regular,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 20,
                                  ),
                                )
                              else
                                const Icon(
                                  FluentIcons.arrow_clockwise_24_regular,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              Text(
                                _serverRunning
                                    ? S.of(context).waitingAClientConnection
                                    : S.of(context).serverIsStopped,
                                style: const TextStyle(fontSize: 14.0),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                          if (_serverRunning)
                            const SizedBox(height: 20)
                          else
                            const SizedBox(height: 4),
                        ],
                      )
                    else
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: <Widget>[
                          if (_isDiscovering || _isConnecting)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          else
                            const Icon(
                              FluentIcons.warning_24_regular,
                              size: 20,
                              color: Colors.red,
                            ),
                          Text(
                            _isDiscovering
                                ? S
                                    .of(context)
                                    .discoveringSeconds(_discoverySeconds)
                                : _isConnecting
                                    ? S.of(context).connectingAttempt(
                                        _currentAttempt, _maxAttempt)
                                    : _discoverySuccess
                                        ? S
                                            .of(context)
                                            .discoverySuccessfulAwaitingConnection
                                        : S
                                            .of(context)
                                            .networkStatusDisconnected,
                            style: const TextStyle(fontSize: 14.0),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),


                    if (_protocolMismatchMessage != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _protocolMismatchMessage!,
                        style:
                            const TextStyle(fontSize: 14.0, color: Colors.red),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],

                    const SizedBox(height: 8),


                    if (isHost && _serverRunning && _hostInfo.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _hostInfo,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 0),
                  ],
                ),
              ),
            ),


            if (isHost)
              Container(
                height: 160.0,
                padding: const EdgeInsets.only(top: 4.0),
                child: _buildHostUI(),
              )
            else
              Container(
                padding: const EdgeInsets.only(top: 4.0),
                child: _buildJoinUI(),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildHostUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio<bool>(
              value: true,
              groupValue: _hostPlaysWhite,
              onChanged: _serverRunning
                  ? null
                  : (bool? val) {
                      setState(() {
                        _hostPlaysWhite = val ?? true;
                      });
                    },
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: DB().colorSettings.whitePieceColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 40),
            Radio<bool>(
              value: false,
              groupValue: _hostPlaysWhite,
              onChanged: _serverRunning
                  ? null
                  : (bool? val) {
                      setState(() {
                        _hostPlaysWhite = val ?? false;
                      });
                    },
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: DB().colorSettings.blackPieceColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),


        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            icon: Icon(
              _serverRunning
                  ? FluentIcons.stop_24_regular
                  : FluentIcons.play_24_filled,
              size: 20,
            ),
            label: Text(
              _serverRunning
                  ? S.of(context).stopHosting
                  : S.of(context).startHosting,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            onPressed: () async {
              if (_serverRunning) {
                await _stopHosting();
              } else {
                await _startHosting();
              }
            },
          ),
        ),
      ],
    );
  }


  Widget _buildJoinUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: S.of(context).serverIp,
                  errorText: _ipError,
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: S.of(context).port,
                  errorText: _portError,
                  errorMaxLines: 3,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () async {
                  if (_isDiscovering) {
                    _cancelDiscovery();
                  } else {
                    await _startDiscovery();
                  }
                },
                child: Text(
                  _isDiscovering ? S.of(context).stop : S.of(context).discover,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: _onConnect,
                child: Text(
                  S.of(context).connect,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
