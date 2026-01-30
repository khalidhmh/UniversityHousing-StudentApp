import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/clearance_view_model.dart';
// import '../widgets/clearance/clearance_timeline_card.dart'; // تأكد من المسار

class ClearanceScreen extends StatefulWidget {
  const ClearanceScreen({Key? key}) : super(key: key);

  @override
  State<ClearanceScreen> createState() => _ClearanceScreenState();
}

class _ClearanceScreenState extends State<ClearanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClearanceViewModel>().loadClearanceStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('إخلاء الطرف', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ClearanceViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // الحالة 1: لم يبدأ الإخلاء بعد
          if (vm.status == 'none') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_return_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'لم تقم ببدء إجراءات الإخلاء بعد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await vm.initiateClearance();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('بدء إجراءات الإخلاء'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  )
                ],
              ),
            );
          }

          // الحالة 2: يوجد طلب (سواء معلق، مقبول، أو مرفوض)
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // كارت الحالة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getStatusColor(vm.status),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(vm.status), color: Colors.white, size: 40),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('حالة الطلب', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(
                            _getStatusText(vm.status),
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // الخطوات (Stepper)
                Expanded(
                  child: Stepper(
                    currentStep: vm.currentStep,
                    controlsBuilder: (context, details) => Container(), // إخفاء أزرار الـ Stepper الافتراضية
                    steps: [
                      Step(
                        title: const Text('تقديم الطلب'),
                        content: const Text('تم تقديم طلب الإخلاء بنجاح للمشرف المختص.'),
                        isActive: vm.currentStep >= 0,
                        state: vm.currentStep > 0 ? StepState.complete : StepState.indexed,
                      ),
                      Step(
                        title: const Text('مراجعة المشرف & فحص الغرفة'),
                        content: const Text('جاري مراجعة العهدة وفحص الغرفة من قبل المشرف.'),
                        isActive: vm.currentStep >= 1,
                        state: vm.currentStep > 1 ? StepState.complete : (vm.status == 'pending' ? StepState.editing : StepState.indexed),
                      ),
                      Step(
                        title: const Text('إتمام الإخلاء'),
                        content: Text(vm.status == 'approved' ? 'تم اعتماد الإخلاء بنجاح.' : 'في انتظار الاعتماد النهائي.'),
                        isActive: vm.currentStep >= 2,
                        state: vm.status == 'approved' ? StepState.complete : StepState.indexed,
                      ),
                    ],
                  ),
                ),

                // عرض ملاحظات المشرف في حالة الرفض
                if (vm.status == 'rejected' && vm.notes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(child: Text('ملاحظات المشرف: ${vm.notes}')),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'pending': return Icons.hourglass_top;
      default: return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved': return 'تم الإخلاء';
      case 'rejected': return 'مرفوض';
      case 'pending': return 'قيد المراجعة';
      default: return 'غير معروف';
    }
  }
}