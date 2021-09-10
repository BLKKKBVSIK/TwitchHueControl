import 'models/TwitchHueBot.dart';

void main() async {
  final client = TwitchHueBot();

  try {
    await client.detectLocalHueBridge();
    await client.connectToHueBridge();
    await client.detectSurroundingHueLights();
    await client.connectToTwitchChat();
  } catch (e) {
    print(e);
  }
}
