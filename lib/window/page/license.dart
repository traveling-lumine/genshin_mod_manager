// https://github.com/espresso3389/flutter_oss_licenses
// example/lib/main.dart
//
// MIT License
//
// Copyright (c) 2019 Takashi Kawasaki
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/oss_licenses.dart';
import 'package:url_launcher/url_launcher.dart';

class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

  static Future<List<Package>> loadLicenses() async {
    // merging non-dart dependency list using LicenseRegistry.
    final lm = <String, List<String>>{};
    await for (var l in LicenseRegistry.licenses) {
      for (var p in l.packages) {
        final lp = lm.putIfAbsent(p, () => []);
        lp.addAll(l.paragraphs.map((p) => p.text));
      }
    }
    final licenses = ossLicenses.where((e) => e.isDirectDependency).toList();
    // for (var key in lm.keys) {
    //   licenses.add(Package(
    //     name: key,
    //     description: '',
    //     authors: [],
    //     version: '',
    //     license: lm[key]!.join('\n\n'),
    //     isMarkdown: false,
    //     isSdk: false,
    //     isDirectDependency: false,
    //   ));
    // }
    return licenses..sort((a, b) => a.name.compareTo(b.name));
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('Open Source Licenses'),
      ),
      content: ScaffoldPage(
          content: FutureBuilder<List<Package>>(
              future: _licenses,
              initialData: const [],
              builder: (context, snapshot) {
                return ListView.separated(
                    padding: const EdgeInsets.all(0),
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final package = snapshot.data![index];
                      return ListTile(
                        title: Text('${package.name} ${package.version}'),
                        subtitle: package.description.isNotEmpty
                            ? Text(package.description)
                            : null,
                        trailing: const Icon(FluentIcons.chevron_right),
                        onPressed: () => Navigator.of(context).push(
                          FluentPageRoute(
                            builder: (context) =>
                                MiscOssLicenseSingle(package: package),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider());
              })),
    );
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final Package package;

  const MiscOssLicenseSingle({super.key, required this.package});

  String _bodyText() {
    return package.license!.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text('${package.name} ${package.version}'),
      ),
      content: ScaffoldPage(
        content: ListView(children: <Widget>[
          if (package.description.isNotEmpty)
            Padding(
                padding:
                    const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                child: Text(
                  package.description,
                )),
          if (package.homepage != null)
            Padding(
                padding:
                    const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                child: GestureDetector(
                  child: Text(package.homepage!,
                      style: const TextStyle(
                          decoration: TextDecoration.underline)),
                  onTap: () => launchUrl(Uri.parse(package.homepage!)),
                )),
          if (package.description.isNotEmpty || package.homepage != null)
            const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
            child: Text(_bodyText()),
          ),
        ]),
      ),
    );
  }
}
