import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for Maintenance Request
class MaintenanceRequest {
  final String id;
  final String category;
  final String title;
  final String location;
  final String status; // 'تم الإصلاح', 'قيد الانتظار'
  final DateTime date;

  MaintenanceRequest({
    required this.id,
    required this.category,
    required this.title,
    required this.location,
    required this.status,
    required this.date,
  });
}

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  late List<MaintenanceRequest> requests;

  @override
  void initState() {
    super.initState();
    requests = _getDummyRequests();
  }

  List<MaintenanceRequest> _getDummyRequests() {
    return [
      MaintenanceRequest(
        id: '1',
        category: 'كهرباء',
        title: 'انقطاع الكهرباء عن الغرفة',
        location: 'غرفة 304 - مبنى أ',
        status: 'تم الإصلاح',
        date: DateTime(2026, 1, 18),
      ),
      MaintenanceRequest(
        id: '2',
        category: 'سباكة',
        title: 'تسريب من الحنفية',
        location: 'حمام مشترك - الدور الثالث',
        status: 'قيد الانتظار',
        date: DateTime(2026, 1, 19),
      ),
      MaintenanceRequest(
        id: '3',
        category: 'نجارة',
        title: 'باب الغرفة مكسور',
        location: 'غرفة 305 - مبنى أ',
        status: 'تم الإصلاح',
        date: DateTime(2026, 1, 15),
      ),
      MaintenanceRequest(
        id: '4',
        category: 'ألوميتال',
        title: 'نافذة الغرفة بحاجة إلى إصلاح',
        location: 'غرفة 402 - مبنى ب',
        status: 'قيد الانتظار',
        date: DateTime(2026, 1, 19),
      ),
    ];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'كهرباء':
        return Icons.electrical_services;
      case 'سباكة':
        return Icons.plumbing;
      case 'نجارة':
        return Icons.carpenter;
      case 'ألوميتال':
        return Icons.window;
      case 'غاز':
        return Icons.local_gas_station;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'طلبات الصيانة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildMaintenanceCard(requests[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewReportBottomSheet(context);
        },
        backgroundColor: const Color(0xFFF2C94C),
        child: const Icon(
          Icons.add,
          color: Color(0xFF001F3F),
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceRequest request) {
    Color statusBgColor;
    Color statusTextColor;

    if (request.status == 'تم الإصلاح') {
      statusBgColor = Colors.green.withOpacity(0.1);
      statusTextColor = Colors.green;
    } else {
      statusBgColor = Colors.amber.withOpacity(0.1);
      statusTextColor = Colors.amber[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon (Left)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(request.category),
              size: 24,
              color: const Color(0xFF001F3F),
            ),
          ),
          const SizedBox(width: 12),
          // Request Details (Center)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.location,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status Badge (Right)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              request.status,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return const _NewReportForm();
      },
    );
  }
}

class _NewReportForm extends StatefulWidget {
  const _NewReportForm();

  @override
  State<_NewReportForm> createState() => __NewReportFormState();
}

class __NewReportFormState extends State<_NewReportForm> {
  String? selectedCategory;
  final TextEditingController descriptionController = TextEditingController();
  bool hasPhoto = false;

  final List<String> categories = [
    'سباكة',
    'كهرباء',
    'نجارة',
    'ألوميتال',
    'غاز',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'كهرباء':
        return Icons.electrical_services;
      case 'سباكة':
        return Icons.plumbing;
      case 'نجارة':
        return Icons.carpenter;
      case 'ألوميتال':
        return Icons.window;
      case 'غاز':
        return Icons.local_gas_station;
      default:
        return Icons.build;
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (selectedCategory == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى اختيار نوع العطل وكتابة الوصف',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال البلاغ بنجاح',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF001F3F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإبلاغ عن الأعطال',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر نوع العطل لنقوم بإرسال الفني المختص',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: List.generate(categories.length, (index) {
                String category = categories[index];
                bool isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF9E6)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF2C94C)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isSelected ? 0.12 : 0.06,
                          ),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 32,
                          color: isSelected
                              ? const Color(0xFFF2C94C)
                              : const Color(0xFF001F3F),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF001F3F),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Description Field
            Text(
              'وصف العطل',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: 3,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: 'اكتب تفاصيل العطل هنا...',
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photo Upload
            Text(
              'الصورة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تحميل الصورة - قيد التطوير',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF001F3F),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Color(0xFF001F3F),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'التقاط صورة أو رفع ملف',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF001F3F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2C94C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'إرسال البلاغ',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
