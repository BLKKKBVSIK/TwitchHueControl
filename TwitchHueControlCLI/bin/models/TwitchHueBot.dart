import 'dart:convert';
import 'dart:io';
import 'package:cli_menu/cli_menu.dart';
import 'package:color_models/color_models.dart';
import 'package:hue_dart/hue_dart.dart';
import 'package:http/http.dart' as http;
import 'package:tmi/tmi.dart' as tmi;

class TwitchHueBot {
  Bridge? _hueBridge;
  String? _hueUserHash;
  Light? _selectedLight;

  Future detectLocalHueBridge() async {
    final client = http.Client();
    final discovery = BridgeDiscovery(client);
    var discoverResults = await discovery.automatic();

    if (discoverResults.isEmpty) {
      throw ('No hue bridge discovered');
    }
    print('Hue Bridge discovered on ${discoverResults.first.ipAddress}\n\n');

    _hueBridge = Bridge(client, discoverResults.first.ipAddress!);
  }

  Future connectToHueBridge() async {
    print('STEP 2: FETCHING HUE BRIDGE USER\n');

    if (await File('TwitchHueBotConfig.ini').exists()) {
      print('User fetched from TwitchHueBotConfig.ini\n\n');
      _hueUserHash = (await File('TwitchHueBotConfig.ini').readAsLines())
          .first
          .split(':')
          .last;
      _hueBridge?.username = _hueUserHash!;
    } else {
      var _init = false;
      print(
          'No user fetched from config files, please push on the Hue Bridge button.\nAwaiting.');
      var i = 0;
      while (!_init) {
        try {
          final whiteListItem =
              await _hueBridge?.createUser('hue#twitchhuebot');
          _hueBridge?.username = (_hueUserHash = whiteListItem?.username)!;
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
  }

  Future detectSurroundingHueLights() async {
    final lights = await _hueBridge!.lights();
    var roomsName = <String?>[];
    Light? selectedLight;

    if (lights.isNotEmpty) {
      for (var light in lights) {
        roomsName.add(light.name);
      }

      print('Select your light (Use arrows (if supported), or type number):');
      final menu = Menu(roomsName);
      final result = menu.choose();

      selectedLight = lights[roomsName.indexOf(result.value)];
    }
    print(roomsName.contains(selectedLight).toString());
    _selectedLight = selectedLight;
  }

  Future connectToTwitchChat() async {
    String? channelName;
    print('\nSTEP 3: CONNECTING TO YOUR TWITCH CHANNEL CHAT\n');

    if (await File('TwitchHueBotConfig.ini').exists() &&
        (await File('TwitchHueBotConfig.ini').readAsLines()).length > 2) {
      channelName = (await File('TwitchHueBotConfig.ini').readAsLines())
          .elementAt(1)
          .split(':')
          .last;

      print(channelName);
    } else {
      print('Enter your channel name:');
      var channelName =
          stdin.readLineSync(encoding: Encoding.getByName('utf-8')!) ?? '';
      if (channelName.isEmpty) {
        throw ("Can't connect to this channel");
      }

      if (await File('TwitchHueBotConfig.ini').exists()) {
        var f = File('TwitchHueBotConfig.ini');
        final link = f.openWrite(mode: FileMode.append);
        link.writeln('\nchannelName:$channelName');
        await link.close();
      } else {
        throw ('TwitchHueBotConfig.ini not found');
      }
    }
    print('Awaiting connection to "$channelName" Twitch channel');
    var client = tmi.Client(
      channels: '${channelName!.trim()}',
      secure: true,
    );
    client.connect();
    print(
        '\nYour program is now ready, type !color <hexValue> in your twitch chat');
    client.on('message', (String channel, _, String message, __) async {
      if (message.toLowerCase().startsWith('!color ')) {
        var color = message.split(' ').last;
        if (color.isNotEmpty) {
          final regExp = RegExp(r'[0-9A-F]{6}', caseSensitive: false);
          if (regExp.hasMatch(color)) {
            await _updateSelectedLightColor(
                selectedLight: _selectedLight!,
                hueBridge: _hueBridge!,
                color: '${regExp.firstMatch(color)!.group(0)}');
          }
        }
      }
    });
  }

  LightState _lightStateForColorOnly({required Light light, int? brightness}) {
    LightState state;
    if (light.state!.colorMode == 'xy') {
      state = LightState((b) {
        b.xy = light.state!.xy!.toBuilder();
        b.brightness = brightness;
      });
    } else if (light.state!.colorMode == 'ct') {
      state = LightState((b) => b..ct = light.state!.ct);
    } else {
      state = LightState((b) => b
        ..hue = light.state!.hue
        ..saturation = light.state!.saturation
        ..brightness = light.state!.brightness);
    }
    return state;
  }

  Future _updateSelectedLightColor(
      {required Light selectedLight,
      required Bridge hueBridge,
      String? color}) async {
    final _assignedColor = RgbColor.fromHex('$color');
    var _assignedBrightness = 254;
    var _updatedSelectedLight = selectedLight;

    if (_assignedColor.isBlack) {
      _assignedBrightness = 0;
    } else {
      _updatedSelectedLight = selectedLight.changeColor(
        red: (_assignedColor.red / 255).toDouble(),
        green: (_assignedColor.green / 255).toDouble(),
        blue: (_assignedColor.blue / 255).toDouble(),
      );
    }

    var state = _lightStateForColorOnly(
        light: _updatedSelectedLight, brightness: _assignedBrightness);
    await hueBridge.updateLightState(selectedLight.rebuild((l) {
      l.state = state.toBuilder();
    }));
  }
}
