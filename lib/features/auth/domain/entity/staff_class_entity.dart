class StaffClassEntity {
  final String id; // id رکورد Staff_Class
  final String role; // teacher / assistant / supervisor
  final String staffId; // id کارمند
  final String firstName;
  final String lastName;

  const StaffClassEntity({
    required this.id,
    required this.role,
    required this.staffId,
    required this.firstName,
    required this.lastName,
  });
}
