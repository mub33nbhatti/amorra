import 'package:flutter/material.dart';
import '../../../core/utils/app_colors/app_colors.dart';
import '../../../core/utils/app_responsive/app_responsive.dart';
import '../../../core/utils/app_styles/app_text_styles.dart';

/// Instagram/Threads-style Date Picker Widget
/// Displays 3 separate wheels for Month, Day, and Year
class AppDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateChanged;

  const AppDatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  DateTime? _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;
  
  // Track selected indices for UI updates
  int _selectedMonthIndex = 5; // Default to June
  int _selectedDayIndex = 14; // Default to day 15
  int _selectedYearIndex = 0;

  // Month names
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();

    _firstDate = widget.firstDate ?? DateTime(DateTime.now().year - 120, 1, 1);
    _lastDate = widget.lastDate ?? DateTime.now();
    
    // If initialDate is provided, use it; otherwise start with null (empty/placeholder)
    _selectedDate = widget.initialDate;

    // Initialize controllers - start at middle of range if no initial date
    if (_selectedDate != null) {
      _selectedMonthIndex = _selectedDate!.month - 1;
      _selectedDayIndex = _selectedDate!.day - 1;
      _selectedYearIndex = _selectedDate!.year - _firstDate.year;
      
      _monthController = FixedExtentScrollController(initialItem: _selectedMonthIndex);
      _dayController = FixedExtentScrollController(initialItem: _selectedDayIndex);
      _yearController = FixedExtentScrollController(initialItem: _selectedYearIndex);
    } else {
      // Start at middle of range (neutral position)
      final middleYear = _firstDate.year + ((_lastDate.year - _firstDate.year) ~/ 2);
      final middleMonth = 6; // June (middle of year)
      final middleDay = 15; // Middle of month
      
      _selectedMonthIndex = middleMonth - 1;
      _selectedDayIndex = middleDay - 1;
      _selectedYearIndex = middleYear - _firstDate.year;
      
      _monthController = FixedExtentScrollController(initialItem: _selectedMonthIndex);
      _dayController = FixedExtentScrollController(initialItem: _selectedDayIndex);
      _yearController = FixedExtentScrollController(initialItem: _selectedYearIndex);
    }

    // Add listeners to update date when wheels scroll
    _monthController.addListener(_onMonthChanged);
    _dayController.addListener(_onDayChanged);
    _yearController.addListener(_onYearChanged);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onMonthChanged() {
    if (_monthController.hasClients && _monthController.position.hasContentDimensions) {
      setState(() {
        _selectedMonthIndex = _monthController.selectedItem;
      });
      _updateDate(month: _selectedMonthIndex + 1);
    }
  }

  void _onDayChanged() {
    if (_dayController.hasClients && _dayController.position.hasContentDimensions) {
      setState(() {
        _selectedDayIndex = _dayController.selectedItem;
      });
      _updateDate(day: _selectedDayIndex + 1);
    }
  }

  void _onYearChanged() {
    if (_yearController.hasClients && _yearController.position.hasContentDimensions) {
      setState(() {
        _selectedYearIndex = _yearController.selectedItem;
      });
      final year = _firstDate.year + _selectedYearIndex;
      _updateDate(year: year);
    }
  }

  void _updateDate({int? month, int? day, int? year}) {
    // If no date was selected before, initialize from current wheel positions
    if (_selectedDate == null) {
      final currentMonth = month ?? (_monthController.hasClients ? _monthController.selectedItem + 1 : 6);
      final currentYear = year ?? (_yearController.hasClients 
          ? _firstDate.year + _yearController.selectedItem 
          : _firstDate.year + ((_lastDate.year - _firstDate.year) ~/ 2));
      final currentDay = day ?? (_dayController.hasClients ? _dayController.selectedItem + 1 : 15);
      _selectedDate = DateTime(currentYear, currentMonth, currentDay);
    }

    final newMonth = month ?? _selectedDate!.month;
    final newYear = year ?? _selectedDate!.year;
    final maxDay = _getDaysInMonth(newMonth, newYear);
    final newDay = day != null ? (day > maxDay ? maxDay : day) : _selectedDate!.day;

    // Ensure day doesn't exceed max days in month
    final adjustedDay = newDay > maxDay ? maxDay : newDay;

    final newDate = DateTime(newYear, newMonth, adjustedDay);

    // Clamp date to valid range
    if (newDate.isBefore(_firstDate)) {
      _selectedDate = _firstDate;
    } else if (newDate.isAfter(_lastDate)) {
      _selectedDate = _lastDate;
    } else {
      _selectedDate = newDate;
    }

    // Update day controller if month/year changed
    if (month != null || year != null) {
      final maxDays = _getDaysInMonth(_selectedDate!.month, _selectedDate!.year);
      if (_selectedDate!.day > maxDays) {
        _selectedDate = DateTime(_selectedDate!.year, _selectedDate!.month, maxDays);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dayController.hasClients) {
          final newDayIndex = (_selectedDate!.day - 1).clamp(0, maxDays - 1);
          _selectedDayIndex = newDayIndex;
          if (_dayController.selectedItem != newDayIndex) {
            _dayController.animateToItem(
              newDayIndex,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }

    widget.onDateChanged?.call(_selectedDate!);
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  List<int> _getDaysForMonth(int month, int year) {
    final daysInMonth = _getDaysInMonth(month, year);
    return List.generate(daysInMonth, (index) => index + 1);
  }

  List<int> _getYears() {
    final years = <int>[];
    for (int year = _firstDate.year; year <= _lastDate.year; year++) {
      years.add(year);
    }
    return years;
  }

  @override
  Widget build(BuildContext context) {
    // Get current wheel positions for calculations
    final currentMonth = _monthController.hasClients 
        ? _monthController.selectedItem + 1 
        : _selectedMonthIndex + 1;
    final currentYear = _yearController.hasClients 
        ? _firstDate.year + _yearController.selectedItem 
        : _firstDate.year + _selectedYearIndex;
    
    final days = _getDaysForMonth(currentMonth, currentYear);
    final years = _getYears();
    
    // Ensure day index is within valid range
    final validDayIndex = _selectedDayIndex.clamp(0, days.length - 1);

    return Container(
      height: AppResponsive.screenHeight(context) * 0.25,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          // Month Wheel
          Expanded(
            child: _buildWheel(
              context,
              items: _months,
              controller: _monthController,
              selectedIndex: _selectedMonthIndex,
            ),
          ),
          // Day Wheel
          Expanded(
            child: _buildWheel(
              context,
              items: days.map((d) => d.toString()).toList(),
              controller: _dayController,
              selectedIndex: validDayIndex,
            ),
          ),
          // Year Wheel
          Expanded(
            child: _buildWheel(
              context,
              items: years.map((y) => y.toString()).toList(),
              controller: _yearController,
              selectedIndex: _selectedYearIndex,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel(
    BuildContext context, {
    required List<String> items,
    required FixedExtentScrollController controller,
    required int selectedIndex,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: AppResponsive.screenHeight(context) * 0.05,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.003,
      diameterRatio: 1.5,
      squeeze: 1.0,
      useMagnifier: true,
      magnification: 1.2,
      onSelectedItemChanged: (index) {
        // Update state when selection changes to trigger rebuild
        setState(() {
          if (controller == _monthController) {
            _selectedMonthIndex = index;
          } else if (controller == _dayController) {
            _selectedDayIndex = index;
          } else if (controller == _yearController) {
            _selectedYearIndex = index;
          }
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= items.length) {
            return null;
          }
          final isSelected = index == selectedIndex;
          return Center(
            child: Text(
              items[index],
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, isSelected ? 18 : 16),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.black : AppColors.grey,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

