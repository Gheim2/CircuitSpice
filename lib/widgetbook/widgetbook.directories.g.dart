// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:circuit_spice/widgetbook/ui/components/context_toolbar_usecase.dart'
    as _circuit_spice_widgetbook_ui_components_context_toolbar_usecase;
import 'package:circuit_spice/widgetbook/ui/components/toolbar_usecase.dart'
    as _circuit_spice_widgetbook_ui_components_toolbar_usecase;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'ui',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ContextToolbar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Standard Toolbar',
            builder:
                _circuit_spice_widgetbook_ui_components_context_toolbar_usecase
                    .buildContextToolbarUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'WorkspaceToolbar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Standard Bottom Bar',
            builder: _circuit_spice_widgetbook_ui_components_toolbar_usecase
                .buildWorkspaceToolbarUseCase,
          ),
        ],
      ),
    ],
  ),
];
