class LearnerStats {
  final int completedBookings;
  final int upcomingBookings;
  final int activeRentals;
  final double totalSpent;
  final double affiliateEarnings;
  final int coursesEnrolled;

  LearnerStats({
    this.completedBookings = 0,
    this.upcomingBookings = 0,
    this.activeRentals = 0,
    this.totalSpent = 0.0,
    this.affiliateEarnings = 0.0,
    this.coursesEnrolled = 0,
  });

  factory LearnerStats.fromJson(Map<String, dynamic> json) {
    return LearnerStats(
      completedBookings: json['completed_bookings'] ?? 0,
      upcomingBookings: json['upcoming_bookings'] ?? 0,
      activeRentals: json['active_rentals'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      affiliateEarnings: (json['affiliate_earnings'] ?? 0).toDouble(),
      coursesEnrolled: json['courses_enrolled'] ?? 0,
    );
  }
}
