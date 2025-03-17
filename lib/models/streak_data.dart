class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int targetStreak;
  final Map<DateTime, bool> completionHistory;
  
  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.targetStreak = 3,
    Map<DateTime, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};
  
  double get last30DaysPercentage {
    final now = DateTime.now();
    int completed = 0;
    int total = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      if (completionHistory.containsKey(normalizedDate)) {
        total++;
        if (completionHistory[normalizedDate] == true) {
          completed++;
        }
      }
    }
    
    return total > 0 ? (completed / total) * 100 : 0;
  }
  
  List<MapEntry<DateTime, bool>> getHistoryForPeriod(int days) {
    final now = DateTime.now();
    final result = <MapEntry<DateTime, bool>>[];
    
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      if (completionHistory.containsKey(normalizedDate)) {
        result.add(MapEntry(normalizedDate, completionHistory[normalizedDate]!));
      } else {
        result.add(MapEntry(normalizedDate, false));
      }
    }
    
    return result;
  }
  
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    int? targetStreak,
    Map<DateTime, bool>? completionHistory,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      targetStreak: targetStreak ?? this.targetStreak,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }
  
  StreakData addCompletionDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final newHistory = Map<DateTime, bool>.from(completionHistory);
    newHistory[normalizedDate] = true;
    
    // Calculate new streak
    int streak = 0;
    final now = DateTime.now();
    
    for (int i = 0; i <= currentStreak + 1; i++) {
      final checkDate = DateTime(now.year, now.month, now.day - i);
      final normalizedCheckDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
      
      if (newHistory[normalizedCheckDate] == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return copyWith(
      currentStreak: streak,
      longestStreak: streak > longestStreak ? streak : longestStreak,
      completionHistory: newHistory,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'targetStreak': targetStreak,
      'completionHistory': completionHistory.map((key, value) => 
          MapEntry(key.millisecondsSinceEpoch.toString(), value)),
    };
  }
  
  factory StreakData.fromMap(Map<String, dynamic> map) {
    final historyMap = map['completionHistory'] as Map<String, dynamic>? ?? {};
    final completionHistory = historyMap.map((key, value) => 
        MapEntry(DateTime.fromMillisecondsSinceEpoch(int.parse(key)), value as bool));
    
    return StreakData(
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      targetStreak: map['targetStreak'] ?? 3,
      completionHistory: completionHistory,
    );
  }
}

