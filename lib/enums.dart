import 'package:enum_to_string/enum_to_string.dart';

enum ChatState {
  CREATED,
  LIVE,
  COMPLETED,
  DELETED,
}

extension ChatStateExtension on ChatState {
  String get name => EnumToString.convertToString(this);
}

enum ChatUserStatus { NORESPONSE, ACCEPTED, DECLINED, DISCONNECTED }

enum DemographicQuestionType { dropdown, textfield, multiselect }
