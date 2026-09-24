import 'package:flutter/material.dart';

class EmployeeFilterBar extends StatefulWidget {
  final void Function(String? name, String? email, String? mobile, String? country) onFilter;
  final VoidCallback onClear;
  final bool hasActiveFilters;

  const EmployeeFilterBar({
    super.key,
    required this.onFilter,
    required this.onClear,
    required this.hasActiveFilters,
  });

  @override
  State<EmployeeFilterBar> createState() => _EmployeeFilterBarState();
}

class _EmployeeFilterBarState extends State<EmployeeFilterBar> {
  bool _isExpanded = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    widget.onFilter(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _mobileController.text.trim(),
      _countryController.text.trim(),
    );
  }

  void _clearAll() {
    _nameController.clear();
    _emailController.clear();
    _mobileController.clear();
    _countryController.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: Text(
                  _isExpanded ? 'Hide Filters' : 'Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.hasActiveFilters
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                selected: widget.hasActiveFilters || _isExpanded,
                onSelected: (_) => setState(() => _isExpanded = !_isExpanded),
                avatar: Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: widget.hasActiveFilters
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: widget.hasActiveFilters
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              if (widget.hasActiveFilters) ...[
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: _clearAll,
                  avatar: const Icon(Icons.close_rounded, size: 14),
                  backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.3),
                  labelStyle: TextStyle(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Filter name',
                            isDense: true,
                            prefixIcon: const Icon(Icons.person_outline, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Filter email',
                            isDense: true,
                            prefixIcon: const Icon(Icons.email_outlined, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mobileController,
                          decoration: InputDecoration(
                            labelText: 'Mobile',
                            hintText: 'Filter mobile',
                            isDense: true,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _countryController,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            hintText: 'Filter country',
                            isDense: true,
                            prefixIcon: const Icon(Icons.public_outlined, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
