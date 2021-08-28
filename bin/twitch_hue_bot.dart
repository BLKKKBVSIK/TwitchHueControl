import 'dart:convert';
import 'dart:io';
import 'package:cli_menu/cli_menu.dart';
import 'package:color_models/color_models.dart';
import 'package:http/http.dart' as http;
import 'package:hue_dart/hue_dart.dart';
import 'package:tmi/tmi.dart' as tmi;

void main() async {
  Bridge hueBridge;
  var _init = false;
  String _hueUserHash;

  print('STEP 1: DETECTING HUE BRIDGE ON LOCAL NETWORK\n');
  hueBridge ??= await detectHueBridge();

  print('STEP 2: FETCHING HUE BRIDGE USER\n');

  if (await File('TwitchHueBotConfig.ini').exists()) {
    print('User fetched from TwitchHueBotConfig.ini\n\n');
    _hueUserHash =
        (await File('TwitchHueBotConfig.ini').readAsString()).split(':').last;
    hueBridge.username = _hueUserHash;
  } else {
    print(
        'No user fetched from config files, please push on the Hue Bridge button.\nAwaiting.');
    var i = 0;
    while (!_init) {
      try {
        final whiteListItem = await hueBridge.createUser('hue#twitchhuebot');
        hueBridge.username = _hueUserHash = whiteListItem.username;
        _init = true;
      } catch (error) {
        i++;
        if (i >= 20) {
          stdout.write('.');
          i = 0;
        }
      }
    }
    print('\nUser created, saving user to TwitchHueBotConfig.ini\n\n');
    var f = await File('TwitchHueBotConfig.ini').create();
    final link = f.openWrite();
    link.write('hueUserHash:$_hueUserHash');
    await link.close();
  }

  print('STEP 2: FETCHING HUE BRIDGE USER\n');

  var selectedLight = await detectSurroundingHueLights(hueBridge: hueBridge);

  print('\nSTEP 3: CONNECTING TO YOUR TWITCH CHANNEL CHAT\n');

  print('Enter your channel name:');
  var channelName = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));

  print('Awaiting connection to "$channelName" Twitch channel');
  var client = tmi.Client(
    channels: '${channelName.trim()}',
    secure: true,
  );
  client.connect();

  print(
      '\nYour program is now ready, type !color <hexValue> in your twitch chat');

  client.on('message', (String channel, _, String message, __) async {
    if (message.toLowerCase().startsWith('!color ')) {
      var color = message.split(' ').last;
      if (color.isNotEmpty) {
        //TODO: When black color selected, remove the brightness;
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

  if (discoverResults.isEmpty) {
    print('No bridge discover');
    exit(2);
  }
  print('Hue Bridge discovered on ${discoverResults.first.ipAddress}\n\n');

  return Bridge(client, discoverResults.first.ipAddress);
}

LightState lightStateForColorOnly({Light light, int brightness}) {
  LightState state;
  if (light.state.colorMode == 'xy') {
    state = LightState((b) {
      b.xy = light.state.xy.toBuilder();
      b.brightness = brightness;
    });
  } else if (light.state.colorMode == 'ct') {
    state = LightState((b) => b..ct = light.state.ct);
  } else {
    state = LightState((b) => b
      ..hue = light.state.hue
      ..saturation = light.state.saturation
      ..brightness = light.state.brightness);
  }
  return state;
}

Future updateSelectedLightColor(
    {Light selectedLight, Bridge hueBridge, String color}) async {
  final _assignedColor = HsbColor.fromHex('$color');
  var _assignedBrightness = 254;
  var _updatedSelectedLight = selectedLight;

  if (color == '000000') {
    _assignedBrightness = 0;
  } else {
    _updatedSelectedLight = selectedLight.changeColor(
        red: _assignedColor.toXyzColor().x.toDouble(),
        green: _assignedColor.toXyzColor().y.toDouble(),
        blue: _assignedColor.toXyzColor().z.toDouble());
  }
  // 00 00 00

  var state = lightStateForColorOnly(
      light: _updatedSelectedLight, brightness: _assignedBrightness);
  await hueBridge.updateLightState(selectedLight.rebuild((l) {
    l.state = state.toBuilder();
  }));
}

Future<Light> detectSurroundingHueLights({Bridge hueBridge}) async {
  final lights = await hueBridge.lights();
  var roomsName = <String>[];
  Light selectedLight;

  if (lights.isNotEmpty) {
    for (var light in lights) {
      roomsName.add(light.name);
    }

    print('Select your light (Use arrows (if supported), or type number):');
    final menu = Menu(roomsName);
    final result = menu.choose();

    selectedLight = lights[roomsName.indexOf(result.value)];
  }
  return selectedLight;
}
