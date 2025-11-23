import 'package:flutter/material.dart';
import 'package:jante_chai/services/admin_service.dart';
import 'package:jante_chai/services/auth_service.dart';

class ManageReportersScreen extends StatefulWidget {
  const ManageReportersScreen({super.key});

  @override
  State<ManageReportersScreen> createState() => _ManageReportersScreenState();
}

class _ManageReportersScreenState extends State<ManageReportersScreen> {
  List<User> _reporters = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReporters();
  }

  Future<void> _fetchReporters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reporters = await AdminService.fetchReporters();
      setState(() {
        _reporters = reporters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reporters. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(
    String reporterId,
    Map<String, dynamic> data,
  ) async {
    // Optimistic update or show loading indicator for specific row could be better
    // For simplicity, we'll just call the API and refresh
    final success = await AdminService.updateReporterStatus(reporterId, data);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporter status updated to ${data['status']}')),
      );
      _fetchReporters(); // Refresh list to ensure consistency
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reporters')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchReporters,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _reporters.map((reporter) {
                  final status = reporter.status ?? 'Unknown';
                  return DataRow(
                    cells: [
                      DataCell(Text(reporter.name)),
                      DataCell(Text(reporter.email)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(
                        DropdownButton<String>(
                          value:
                              [
                                'approved',
                                'pending',
                                'fired',
                              ].contains(status.toLowerCase())
                              ? status.toLowerCase()
                              : null,
                          hint: const Text('Action'),
                          items: const [
                            DropdownMenuItem(
                              value: 'approved',
                              child: Text('Approve'),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'fired',
                              child: Text('Fire'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null &&
                                status.toLowerCase() != value) {
                              _updateStatus(reporter.id, {'status': value});
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'fired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
