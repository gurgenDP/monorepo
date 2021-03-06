import 'package:guardian/slack/model/slack_message.dart';
import 'package:guardian/slack/model/slack_plain_text_object.dart';
import 'package:guardian/slack/model/slack_section_block.dart';
import 'package:test/test.dart';

void main() {
  group('SlackMessage', () {
    const slackMessage = SlackMessage(
      text: 'test',
      blocks: [
        SlackSectionBlock(
          text: SlackPlainTextObject(text: 'section text'),
        )
      ],
    );

    const slackMessageMap = {
      'text': 'test',
      'blocks': [
        {
          'type': 'section',
          'text': {
            'text': 'section text',
            'type': 'plain_text',
          },
        },
      ],
    };

    test(
      'toJson() should return map with non-null properties of slack message',
      () {
        const message = SlackMessage(text: 'text');
        const expected = {'text': 'text'};
        final map = message.toJson();

        expect(map, equals(expected));
      },
    );

    test(
      'toJson() should include blocks to resulting map if presented',
      () {
        final expected = slackMessageMap['blocks'];
        final map = slackMessage.toJson();

        expect(map, containsPair('blocks', expected));
      },
    );

    test('fromJson() should return null if decoded map is null', () {
      final result = SlackMessage.fromJson(null);

      expect(result, isNull);
    });

    test('fromJson() should convert map to Slack message', () {
      final result = SlackMessage.fromJson(slackMessageMap);

      expect(result, equals(slackMessage));
    });

    test(
      'validate() should result with false if both text and blocks are missing',
      () {
        const message = SlackMessage();
        final result = message.validate();

        expect(result.isValid, isFalse);
      },
    );

    test(
      'validate() should result with false if text is empty on missign blocks',
      () {
        const message = SlackMessage(text: '');
        final result = message.validate();

        expect(result.isValid, isFalse);
      },
    );

    test(
      'validate() should result with false if there is at least one invalid '
      'block in blocks',
      () {
        const message = SlackMessage(blocks: [SlackSectionBlock()]);
        final result = message.validate();

        expect(result.isValid, isFalse);
      },
    );

    test(
      'validate() should result with false if there are more than 50 blocks',
      () {
        final message = SlackMessage(
          blocks: List.generate(
            51,
            (_) => const SlackSectionBlock(
              text: SlackPlainTextObject(text: 'test'),
            ),
          ),
        );
        final result = message.validate();

        expect(result.isValid, isFalse);
      },
    );

    test(
      'validate() should validate slack message',
      () {
        final result = slackMessage.validate();

        expect(result.isValid, isTrue);
      },
    );
  });
}
