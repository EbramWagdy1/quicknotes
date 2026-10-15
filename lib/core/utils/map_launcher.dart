import 'package:url_launcher/url_launcher.dart';

abstract final class MapLauncher {
  const MapLauncher._();

  static Future<bool> openMap(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');

    try {
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {}

    return await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }
}
