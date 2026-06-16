import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/role_definition.dart';

/// Manages the list of roles (built-in + custom).
class RoleNotifier extends StateNotifier<List<RoleDefinition>> {
  RoleNotifier() : super(builtInRoles()) {
    _loadCustomRoles();
  }

  void _loadCustomRoles() {
    // TODO: load from local storage when available
  }

  void _saveCustomRoles() {
    // TODO: persist to local storage when available
  }

  /// Add a new custom role.
  void addRole(RoleDefinition role) {
    state = [...state, role];
    _saveCustomRoles();
  }

  /// Remove a role by id (only custom roles, not built-in).
  void removeRole(String id) {
    final existing = state.where((r) => r.id == id).firstOrNull;
    if (existing != null && existing.isBuiltIn) return;
    state = state.where((r) => r.id != id).toList();
    _saveCustomRoles();
  }

  /// Find a role by mention handle.
  RoleDefinition? findByMention(String mention) {
    return state.where((r) => r.mention == mention).firstOrNull;
  }

  /// Get all non-built-in roles.
  List<RoleDefinition> get customRoles =>
      state.where((r) => !r.isBuiltIn).toList();

  /// Get only built-in roles.
  List<RoleDefinition> get builtInRolesList =>
      state.where((r) => r.isBuiltIn).toList();
}

final roleProvider = StateNotifierProvider<RoleNotifier, List<RoleDefinition>>((ref) {
  return RoleNotifier();
});
