/// Converts time to minutes
int timeToMinutes(String time) {
  final parts = time.split(':');
  final hours = int.parse(parts[0]);
  final minutes = int.parse(parts[1]);
  if (hours == 0) {
    return minutes;
  } else {
    return hours * 60 + minutes;
  }
}
