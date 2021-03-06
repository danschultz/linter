// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.test.config;

import 'package:linter/src/config.dart';
import 'package:unittest/unittest.dart';

main() {
  groupSep = ' | ';

  defineTests();
}

defineTests() {
  const src = """
files:
  include: foo # un-quoted
  exclude:
    - 'test/**'       # file globs can be scalars or lists
    - '**/_data.dart' # unquoted stars treated by YAML as aliases
rules:
  style_guide:
    unnecessary_getters: false #disable
    camel_case_types: true #enable
  pub:
    package_names: false
""";

// In the future, options might be marshaled in maps and passed to rules.
//  acme:
//    some_rule:
//      some_option: # Note this nesting might be arbitrarily complex?
//        - param1
//        - param2

  var config = new LintConfig.parse(src);

  group('lint config', () {
    group('file', () {
      test('includes', () {
        expect(config.fileIncludes, unorderedEquals(['foo']));
      });
      test('excludes', () {
        expect(
            config.fileExcludes, unorderedEquals(['test/**', '**/_data.dart']));
      });
    });
    group('rule', () {
      test('configs', () {
        expect(config.ruleConfigs, hasLength(3));
      });

      test('config', () {
        config = new LintConfig.parse('''
rules:
  style_guide:
    unnecessary_getters: false''');
        expect(config.ruleConfigs, hasLength(1));
        var ruleConfig = config.ruleConfigs[0];
        expect(ruleConfig.group, equals('style_guide'));
        expect(ruleConfig.name, equals('unnecessary_getters'));
        expect(ruleConfig.args, equals({'enabled': false}));
        expect(ruleConfig.disables('unnecessary_getters'), isTrue);
      });
    });
  });
}
