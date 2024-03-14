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

class OssLicensesRoute extends StatelessWidget {
  const OssLicensesRoute({super.key});

  static Future<List<Package>> loadLicenses() async {
    // merging non-dart dependency list using LicenseRegistry.
    final lm = <String, List<String>>{};
    await for (final l in LicenseRegistry.licenses) {
      for (final p in l.packages) {
        final lp = lm.putIfAbsent(p, () => []);
        lp.addAll(l.paragraphs.map((final p) => p.text));
      }
    }
    final licenses = ossLicenses.where((final e) => e.isDirectDependency).toList();
    // for (final key in lm.keys) {
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
    return licenses..sort((final a, final b) => a.name.compareTo(b.name));
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(final BuildContext context) => NavigationView(
      appBar: const NavigationAppBar(
        title: Text('Open Source Licenses'),
      ),
      content: ScaffoldPage(
        content: FutureBuilder<List<Package>>(
          future: _licenses,
          initialData: const [],
          builder: (final context, final snapshot) => ListView.separated(
              padding: const EdgeInsets.all(0),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (final context, final index) {
                final package = snapshot.data![index];
                return ListTile(
                  title: Text('${package.name} ${package.version}'),
                  subtitle: package.description.isNotEmpty
                      ? Text(package.description)
                      : null,
                  trailing: const Icon(FluentIcons.chevron_right),
                  onPressed: () => Navigator.of(context).push(
                    FluentPageRoute(
                      builder: (final context) =>
                          MiscOssLicenseSingle(package: package),
                    ),
                  ),
                );
              },
              separatorBuilder: (final context, final index) => const Divider(),
            ),
        ),
      ),
    );
}

class MiscOssLicenseSingle extends StatelessWidget {

  const MiscOssLicenseSingle({required this.package, super.key});
  final Package package;

  String _bodyText() => package.license!.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');

  @override
  Widget build(final BuildContext context) => NavigationView(
      appBar: NavigationAppBar(
        title: Text('${package.name} ${package.version}'),
      ),
      content: ScaffoldPage(
        content: ListView(children: <Widget>[
          if (package.description.isNotEmpty)
            Padding(
                padding:
                    const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: Text(
                  package.description,
                ),),
          if (package.homepage != null)
            Padding(
                padding:
                    const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: GestureDetector(
                  child: Text(package.homepage!,
                      style: const TextStyle(
                          decoration: TextDecoration.underline,),),
                  onTap: () => launchUrl(Uri.parse(package.homepage!)),
                ),),
          if (package.description.isNotEmpty || package.homepage != null)
            const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Text(_bodyText()),
          ),
        ],),
      ),
    );
  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Package>('package', package));
  }
}
