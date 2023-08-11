
import 'dart:developer';

void superPrint(dynamic content, {dynamic title = 'Super Print'}) {
  var callerFrame = '';
  try {
    final stackTrace = StackTrace.current;
    final frames = stackTrace.toString().split('\n');
    callerFrame = frames[1];
  } catch (e) {
    print(e.toString());
  }


  final dateTime = DateTime.now();
  final dateTimeString =
      '${dateTime.hour} '
      ': ${dateTime.minute} '
      ': ${dateTime.second}.${dateTime.millisecond}';
  print('');
  print(
      '- $title -'
          ' ${callerFrame.split('(').last.replaceAll(')', '')}');
  print('____________________________');
  print(content.toString());
  print('____________________________ $dateTimeString');}
