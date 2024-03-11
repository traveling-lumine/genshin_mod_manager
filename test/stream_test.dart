import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/data/util.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test("latest value test ", () async {
    final BehaviorSubject<int> stream = BehaviorSubject.seeded(3);
    final LatestStream<int> stream_ = vS2LS(stream.stream);
    expect(stream_.latest, 3);
    stream.add(4);
    expect(stream_.latest, 4);
    stream.add(5);
    expect(stream_.latest, 5);
  });
  test("Immediate emit", () async {
    final BehaviorSubject<int> stream = BehaviorSubject.seeded(3);
    final LatestStream<int> stream_ = vS2LS(stream.stream);
    await Future.delayed(const Duration(seconds: 1));
    stream_.stream.listen((event) {
      expect(event, 3);
    });
  });
  test("Not seeded is not emitted", () {
    final BehaviorSubject<int> stream = BehaviorSubject();
    final LatestStream<int> stream_ = vS2LS(stream.stream);
    stream_.stream.listen((event) {
      fail("Should not emit");
    });
  });
}
