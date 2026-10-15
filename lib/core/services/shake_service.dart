import 'package:shake/shake.dart';

class ShakeService {
  ShakeDetector? detector;
  bool isListening = false;

  void startListening({
    required void Function() onShake,
    double shakeThresholdGravity = 2.7,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
  }) {
    stopListening();

    detector = ShakeDetector.autoStart(
      onPhoneShake: (_) => onShake(),
      shakeThresholdGravity: shakeThresholdGravity,
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeCountResetTime: shakeCountResetTime,
    );
    isListening = true;
  }

  void stopListening() {
    detector?.stopListening();
    detector = null;
    isListening = false;
  }

  void dispose() {
    stopListening();
  }
}
