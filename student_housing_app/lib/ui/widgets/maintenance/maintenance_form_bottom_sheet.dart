import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // ⚠️ تأكد من إضافة هذه المكتبة في pubspec.yaml
import '../../../core/viewmodels/maintenance_view_model.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceFormBottomSheet extends StatefulWidget {
  const MaintenanceFormBottomSheet({Key? key}) : super(key: key);

  @override
  State<MaintenanceFormBottomSheet> createState() => _MaintenanceFormBottomSheetState();
}

class _MaintenanceFormBottomSheetState extends State<MaintenanceFormBottomSheet> {
  final _descriptionController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedCategory = 'electricity'; // Default value matching DB Enum

  // قائمة أنواع الصيانة المتوافقة مع الداتا بييز
  final Map<String, String> _categories = {
    'electricity': 'كهرباء',
    'plumbing': 'سباكة',
    'carpentry': 'نجارة',
    'aluminum': 'ألوميتال',
    'gas': 'غاز',
    'internet': 'إنترنت',
  };

  // قائمة أنواع الأماكن
  final Map<String, String> _locations = {
    'room': 'الغرفة',
    'bathroom': 'الحمام',
    'kitchen': 'المطبخ',
    'hallway': 'الطرقة',
    'office': 'أوفيس',
  };

  // دالة اختيار الصورة
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (!mounted) return;
      context.read<MaintenanceViewModel>().setImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaintenanceViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('طلب صيانة جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. نوع الصيانة
                  const Text('نوع الصيانة', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    ),
                    items: _categories.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 15),

                  // 2. مكان العطل (Dropdown جديد)
                  const Text('مكان العطل', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: vm.selectedLocationType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    ),
                    items: _locations.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) => vm.setLocationType(val!),
                  ),
                  const SizedBox(height: 15),

                  // 3. تفاصيل المكان
                  const Text('تفاصيل المكان (الدور، رقم الغرفة...)', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      hintText: 'مثال: الدور الثالث، حمام يمين',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 4. وصف المشكلة
                  const Text('وصف المشكلة', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اشرح العطل بالتفصيل...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 5. إرفاق صورة (الجديد)
                  const Text('إرفاق صورة (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: vm.selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(vm.selectedImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                                SizedBox(height: 5),
                                Text('اضغط لاختيار صورة', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                    ),
                  ),
                  if (vm.selectedImage != null)
                    TextButton.icon(
                      onPressed: () => vm.clearImage(),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),

          // زر الإرسال
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : () async {
                if (_descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة وصف للمشكلة')));
                  return;
                }

                final success = await vm.submitRequest(
                  category: _selectedCategory,
                  description: _descriptionController.text,
                  locationDetails: _detailsController.text.isEmpty ? 'غير محدد' : _detailsController.text,
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب بنجاح'), backgroundColor: Colors.green));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: vm.isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('إرسال الطلب', style: TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}