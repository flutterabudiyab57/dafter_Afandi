/// Length in Unicode code points, which matches SQLite `length()` on TEXT,
/// so domain validation and DB CHECKs agree (research R10).
int codePointLength(String s) => s.runes.length;
