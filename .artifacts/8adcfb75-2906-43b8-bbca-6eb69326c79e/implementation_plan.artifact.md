# Implementation Plan - ShiftMark Staff Management App

Recreate the ShiftMark prototype functionality and UI in the Flutter project. This includes a dual-role interface (Staff and Admin) with features like GPS-verified attendance, leave management, payroll, and administrative dashboards.

## User Review Required

> [!IMPORTANT]
> This implementation will use standard Flutter Material 3 components. I will try to match the prototype's custom styling (colors, shadows, and layouts) as closely as possible using `ThemeData` and custom `Widget`s.

> [!NOTE]
> For complex components like Maps and Charts, I will use popular Flutter packages (`google_maps_flutter` and `fl_chart`). If you prefer not to add these dependencies, I can implement placeholder UI.

## Proposed Changes

The application will be structured into several layers: constants/theme, models, widgets, and screens.

### [Core & Theme]

#### [MODIFY] [main.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/main.dart)
- Set up `MaterialApp` with custom `ThemeData` (Brand color: #0d9488).
- Implement a `RootNavigator` that handles Role switching and Login state.

#### [NEW] [colors.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/app_colors.dart)
- Define color constants from the prototype (brand, ink, muted, green, gold, red).

---

### [Screens - Authentication]

#### [NEW] [login_screen.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/screens/login_screen.dart)
- Recreate the "Welcome back" hero section with blobs.
- Role toggle (Staff/Admin).
- Email and Password fields.
- Sign-in button with arrow icon.

---

### [Screens - Staff View]

#### [NEW] [staff_main_screen.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/screens/staff/staff_main_screen.dart)
- Bottom navigation bar with Home, Attend, Field, Leave, Payslip.

#### [NEW] [staff_home.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/screens/staff/staff_home.dart)
- Header with greeting and avatar.
- Shift card (Check-out button, hours today).
- Statistics cards (Days present, Leave left).
- Recent activity list.

#### [NEW] [staff_attend.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/screens/staff/staff_attend.dart)
- GPS Map placeholder.
- Geofence verification status.
- Selfie/Slide method selector.
- "Slide to punch" custom widget.

---

### [Screens - Admin View]

#### [NEW] [admin_main_screen.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/screens/admin/admin_main_screen.dart)
- Bottom navigation bar with Overview, Team, Reports, Payroll.

#### [NEW] [admin_dashboard.dart](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/lib/screens/admin/admin_dashboard.dart)
- Attendance donut chart (Present/Late/Absent).
- Status summary cards.
- Pending approvals list.

---

### [Configuration]

#### [MODIFY] [pubspec.yaml](file:///C:/Users/DELL/Desktop/flutter projects/staff management/client/pubspec.yaml)
- Add `lucide_icons` (or similar) for prototype-accurate icons.
- Add `google_maps_flutter` (optional, for the attendance map).
- Add `fl_chart` (optional, for the admin dashboard).

## Verification Plan

### Manual Verification
- Verify role switching from the Login screen.
- Test navigation between all tabs for both Staff and Admin.
- Verify that the theme (colors and typography) matches the prototype.
- Check "Slide to punch" interaction.
- Verify layout responsiveness on different screen sizes (mobile focus).
