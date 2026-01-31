import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/viewmodels/maintenance_view_model.dart';

class MaintenanceFormBottomSheet extends StatefulWidget {
  const MaintenanceFormBottomSheet({Key? key}) : super(key: key);

  @override
  State<MaintenanceFormBottomSheet> createState() => _MaintenanceFormBottomSheetState();
}

class _MaintenanceFormBottomSheetState extends State<MaintenanceFormBottomSheet> {
  final _descriptionController = TextEditingController();

  // خريطة الأيقونات والأسماء للأقسام
  final Map<String, Map<String, dynamic>> _categories = {
    'electricity': {'name': 'كهرباء', 'icon': Icons.flash_on},
    'plumbing': {'name': 'سباكة', 'icon': Icons.plumbing},
    'carpentry': {'name': 'نجارة', 'icon': Icons.handyman},
    'aluminum': {'name': 'ألوميتال', 'icon': Icons.grid_view},
    'gas': {'name': 'غاز', 'icon': Icons.local_fire_department},
    'internet': {'name': 'إنترنت', 'icon': Icons.wifi},
    'glass': {'name': 'زجاج', 'icon': Icons.wb_sunny_outlined},
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaintenanceViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 30),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('اختر القسم'),
                  _buildCategoryGrid(vm),

                  if (vm.selectedCategory != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionTitle('تحديد الموقع'),
                    _buildLocationPickers(vm),

                    const SizedBox(height: 25),
                    _buildSectionTitle('وصف العطل'),
                    _buildDescriptionField(),

                    const SizedBox(height: 25),
                    _buildSectionTitle('إرفاق صورة (اختياري)'),
                    _buildImagePicker(vm),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
          _buildSubmitButton(vm),
        ],
      ),
    );
  }

  // --- Widgets البناء المساعدة ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('إبلاغ عن أعطال', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildCategoryGrid(MaintenanceViewModel vm) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        String key = _categories.keys.elementAt(index);
        bool isSelected = vm.selectedCategory == key;
        return GestureDetector(
          onTap: () => vm.setCategory(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF9E7) : Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? const Color(0xFFF2C94C) : Colors.transparent, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_categories[key]!['icon'], color: isSelected ? const Color(0xFFF2C94C) : Colors.grey),
                const SizedBox(height: 5),
                Text(_categories[key]!['name'], style: GoogleFonts.cairo(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationPickers(MaintenanceViewModel vm) {
    return Column(
      children: [
        // اختيار الدور
        _buildDropdown(
          hint: 'اختر الدور',
          value: vm.selectedFloor,
          items: [1, 2, 3, 4, 5, 6].map((f) => DropdownMenuItem(value: f, child: Text('الدور $f'))).toList(),
          onChanged: (val) => vm.setFloor(val as int),
        ),
        const SizedBox(height: 10),
        // اختيار الجناح (مفلتر بناءً على العطل)
        _buildDropdown(
          hint: 'اختر الجناح',
          value: vm.selectedWing,
          items: vm.getAvailableWings().map((w) => DropdownMenuItem(value: w, child: Text('جناح $w'))).toList(),
          onChanged: (val) => vm.setWing(val as String),
        ),
        if (vm.selectedWing != null) ...[
          const SizedBox(height: 10),
          // اختيار نوع المكان (مفلتر)
          _buildDropdown(
            hint: 'نوع المكان',
            value: vm.selectedLocation,
            items: vm.getAvailableLocations().map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (val) => vm.setLocation(val as String),
          ),
        ],
        if (vm.selectedLocation == 'غرفة عادية') ...[
          const SizedBox(height: 10),
          // اختيار رقم الغرفة (مفلتر بناءً على الجناح)
          _buildDropdown(
            hint: 'رقم الغرفة',
            value: vm.selectedRoomNo,
            items: vm.getAvailableRooms().map((r) => DropdownMenuItem(value: r, child: Text('غرفة $r'))).toList(),
            onChanged: (val) => vm.setRoomNo(val as String),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String hint,
    dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged
  }) {
    // 1. نتأكد أولاً هل القيمة الحالية موجودة في القائمة أم لا
    final bool isValid = items.any((item) => item.value == value);

    return DropdownButtonFormField(
      // 2. إذا كانت القيمة موجودة نضعها، وإذا لم تكن (أو كانت false) نضع null
      value: isValid ? value : null,
      hint: Text(hint, style: GoogleFonts.cairo(fontSize: 14)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'اكتب تفاصيل العطل هنا...',
        filled: true, fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildImagePicker(MaintenanceViewModel vm) {
    return GestureDetector(
      onTap: () async {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img != null) vm.setImage(File(img.path));
      },
      child: Container(
        height: 120, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
        child: vm.selectedImage != null
            ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(vm.selectedImage!, fit: BoxFit.cover))
            : const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildSubmitButton(MaintenanceViewModel vm) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF2C94C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: vm.isLoading ? null : () async {
          final success = await vm.submitRequest(description: _descriptionController.text);
          if (success && mounted) Navigator.pop(context);
        },
        child: vm.isLoading ? const CircularProgressIndicator() : Text('إرسال البلاغ', style: GoogleFonts.cairo(color: const Color(0xFF001F3F), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}