import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchInput({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = "Search",
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
    if (widget.readOnly && widget.onTap == null) {
      throw ArgumentError("onTap must be provided when readOnly is true.");
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? Colors.grey.shade900
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              TablerIcons.search,
              color: Colors.grey.shade500,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: widget.readOnly
                  ? GestureDetector(
                      onTap: widget.onTap,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _searchController,
                          readOnly: true,
                          style: const TextStyle(
                            fontSize: 15,
                            decoration: TextDecoration.none,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    )
                  : TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}