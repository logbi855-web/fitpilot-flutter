import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the currently selected bottom-nav tab across the app.
/// 0 = Home, 1 = Workout, 2 = Diet, 3 = Water, 4 = Profile
final selectedTabProvider = StateProvider<int>((ref) => 0);
