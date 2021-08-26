import 'dart:io';
import 'package:color_models/color_models.dart';
import 'package:http/http.dart' as http;
import 'package:hue_dart/hue_dart.dart';
import 'package:tmi/tmi.dart' as tmi;

void main(List<String> args) async {
  Bridge hueBridge;
  bool _init = false;
  String _hueUserHash;

  print('DETECTING HUE BRIDGE ON LOCAL NETWORK');
  hueBridge ??= await detectHueBridge();
  if (hueBridge == null) {
    print('NO HUE BRIDGE DETECTED');
  }

  if (await File('TwitchHueBotConfig.ini').exists()) {
    _hueUserHash =
        (await File('TwitchHueBotConfig.ini').readAsString()).split(':').last;
    hueBridge.username = _hueUserHash;
  } else {
    while (!_init) {
      try {
        final whiteListItem = await hueBridge.createUser('twitchhuebot');
        hueBridge.username = _hueUserHash = whiteListItem.username;
        _init = true; //Disables the while loop
      } catch (error) {
        print('Failed to fetch/create user on hue bridge');
      }
    }
    File f = await File('TwitchHueBotConfig.ini').create();
    final link = f.openWrite();
    link.write('hueUserHash:$_hueUserHash');
    link.close();
  }

  Light selectedLight = await detectSurroundingHueLights(hueBridge: hueBridge);

/* 
  print('');
    var line = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));
    print(line.trim() == '2' ? 'Yup!' : 'Nope :('); */
/* 
  final whiteListItem = await hueBridge.createUser('twitch-hue');
  hueBridge.username = whiteListItem.username; */

  print('CONNECTING TO "${args[0]}" TWITCH CHANNEL');
  var client = tmi.Client(
    channels: '${args[0]}',
    secure: true,
  );
  client.connect();

  client.on('message', (String channel, _, String message, __) async {
    if (message.toLowerCase().startsWith('!color ')) {
      var color = message.split(' ').last;
      if (color.isNotEmpty) {
        final regExp = RegExp(r'[0-9A-F]{6}', caseSensitive: false);
        if (regExp.hasMatch(color)) {
          await updateSelectedLightColor(
              selectedLight: selectedLight,
              hueBridge: hueBridge,
              color: '${regExp.firstMatch(color).group(0)}');
        }
      }
    }
  });
}

Future<Bridge> detectHueBridge() async {
  final client = http.Client();
  final discovery = BridgeDiscovery(client);
  var discoverResults = await discovery.automatic();

  print(discoverResults.first.ipAddress);

  return Bridge(client, discoverResults.first.ipAddress);
}

LightState lightStateForColorOnly(Light _light) {
  LightState state;
  if (_light.state.colorMode == 'xy') {
    state = LightState((b) {
      b..xy = _light.state.xy.toBuilder();
      b..brightness = 254;
    });
  } else if (_light.state.colorMode == 'ct') {
    state = LightState((b) => b..ct = _light.state.ct);
  } else {
    state = LightState((b) => b
      ..hue = _light.state.hue
      ..saturation = _light.state.saturation
      ..brightness = _light.state.brightness);
  }
  return state;
}

Future updateSelectedLightColor(
    {Light selectedLight, Bridge hueBridge, String color}) async {
  final _assignedColor = HsbColor.fromHex('$color');

  final _updatedSelectedLight = selectedLight.changeColor(
      red: _assignedColor.toXyzColor().x,
      green: _assignedColor.toXyzColor().y,
      blue: _assignedColor.toXyzColor().z);

  LightState state = lightStateForColorOnly(_updatedSelectedLight);
  await hueBridge.updateLightState(selectedLight.rebuild((l) {
    l..state = state.toBuilder();
  }));
}

Future<Light> detectSurroundingHueLights({Bridge hueBridge}) async {
  final lights = await hueBridge.lights();

  // TODO: Tell to the user to choose between lights;

  Light selectedLight = lights[1];

  return selectedLight;
}
