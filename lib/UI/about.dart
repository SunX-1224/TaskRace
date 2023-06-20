import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher_string.dart';
import '../Theme/typography.dart';

const about = """
TaskRace is the application version of the idea of a 'todo-app' which can increase the productivity by featuring the effective division of task and a 'reward system' of increasing ranks to further motivate for completion of task in time.\n\n
Improvable factors and any new suggestions can be provided via mail and feel free to follow the socials for any updates, new apps, etc.
""";

const mail = "sunilsapkota1224@gmail.com";
const fbid = "sunil.sapkota.1224";
const subject = "Regarding TaskRace App requests/suggestions/reports";

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const routeName = "/about";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("About Developer", style: TaskRaceTypography.appTitle),
          ],
        ),
      ),
      body: aboutBody(),
    );
  }

  Widget aboutBody() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: const BeveledRectangleBorder(
          side: BorderSide(width: 4, color: Colors.transparent),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(about),
            const Divider(),
            Text("Links", style: TaskRaceTypography.defaultStyle),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: (() => launchUrlString(
                      'https://mail.google.com/mail/?view=cm&fs=1&to=$mail&su=$subject')),
                  icon: const Icon(Icons.mail),
                ),
                IconButton(
                  onPressed: (() =>
                      launchUrlString('https://www.facebook.com/$fbid')),
                  icon: const Icon(Icons.facebook),
                ),
                IconButton(
                  onPressed: (() =>
                      launchUrlString('https://github.com/SunX-1224')),
                  icon: Image.asset("assests/github.png"),
                ),
                IconButton(
                  onPressed: (() => launchUrlString(
                      'https://www.linkedin.com/in/sunil-sapkota-65428b235/')),
                  icon: Image.asset("assests/linkedin.png"),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
