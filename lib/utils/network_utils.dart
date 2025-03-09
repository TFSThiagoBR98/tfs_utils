import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<String> getNetwork() async {
  final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

  // This condition is for demo purposes only to explain every connection type.
  // Use conditions which work for your requirements.
  if (connectivityResult.contains(ConnectivityResult.mobile)) {
    return 'Redes Móveis';
  } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    return 'Wi-Fi';
  } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
    return 'Rede Cabeada';
  } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
    return 'VPN';
  } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
    return 'Bluetooth';
  } else if (connectivityResult.contains(ConnectivityResult.other)) {
    return 'Outro';
  } else if (connectivityResult.contains(ConnectivityResult.none)) {
    return 'Sem Rede disponível';
  } else {
    return 'N/A';
  }
}

InternetConnection getCheckerInternet({
  List<InternetCheckOption>? customCheckOptions,
}) {
  return InternetConnection.createInstance(
      useDefaultOptions: false,
      customCheckOptions: customCheckOptions ??
          [
            InternetCheckOption(
              uri: Uri.parse(
                'https://speed.cloudflare.com',
              ),
            ),
            InternetCheckOption(
              uri: Uri.parse(
                'https://ec2.us-east-1.amazonaws.com/ping',
              ),
            ),
            InternetCheckOption(
              uri: Uri.parse(
                'https://ec2.sa-east-1.amazonaws.com/ping',
              ),
            ),
            InternetCheckOption(
              uri: Uri.parse(
                'https://fsn1-speed.hetzner.com/',
              ),
            ),
          ]);
}
