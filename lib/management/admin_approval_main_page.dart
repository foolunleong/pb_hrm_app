import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pb_hrsystem/management/admin_approvals_view_page.dart';
import 'package:pb_hrsystem/management/admin_history_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../home/dashboard/dashboard.dart';

class ManagementApprovalsPage extends StatefulWidget {
  const ManagementApprovalsPage({super.key});

  @override
  _ManagementApprovalsPageState createState() =>
      _ManagementApprovalsPageState();
}

class _ManagementApprovalsPageState extends State<ManagementApprovalsPage> {
  bool _isApprovalSelected = true;
  List<Map<String, dynamic>> approvalItems = [];
  List<Map<String, dynamic>> historyItems = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchTokenAndData();
  }

  Future<void> fetchTokenAndData() async {
    await retrieveToken();
    if (token != null) {
      fetchData();
    }
  }

  Future<void> retrieveToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    } catch (e) {
      print('Error retrieving token: $e');
    }
  }

  Future<void> fetchData() async {
    const String baseUrl = 'https://demo-application-api.flexiflows.co';

    try {
      // Fetch Approvals data
      final approvalResponse = await http.get(
        Uri.parse('$baseUrl/api/app/tasks/approvals/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (approvalResponse.statusCode == 200) {
        final dynamic approvalData = json.decode(approvalResponse.body);
        if (approvalData is Map<String, dynamic> &&
            approvalData.containsKey('results')) {
          final List<dynamic>? approvalItemsData = approvalData['results'];
          if (approvalItemsData != null) {
            approvalItems = approvalItemsData
                .whereType<Map<String, dynamic>>()
                .where((item) =>
            item['status'] == 'Waiting' ||
                item['status'] == 'Branch Waiting' ||
                item['status'] == 'Unknown')
                .toList();
          }
        }
      }

      // Fetch History data
      final historyResponse = await http.get(
        Uri.parse('$baseUrl/api/app/tasks/approvals/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (historyResponse.statusCode == 200) {
        final dynamic historyData = json.decode(historyResponse.body);
        if (historyData is Map<String, dynamic> &&
            historyData.containsKey('results')) {
          final List<dynamic>? historyItemsData = historyData['results'];
          if (historyItemsData != null) {
            historyItems = historyItemsData
                .whereType<Map<String, dynamic>>()
                .where((item) =>
            item['status'] == 'Approved' || item['status'] == 'reject')
                .toList();
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Waiting':
      case 'Branch Waiting':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Processing':
        return Colors.blue;
      case 'Unknown':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Waiting':
      case 'Branch Waiting':
        return Icons.hourglass_empty;
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Processing':
        return Icons.timelapse;
      case 'Unknown':
        return Icons.help_outline;
      default:
        return Icons.cancel;
    }
  }

  void _openApprovalDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminApprovalsViewPage(item: item),
      ),
    );
  }

  void _openHistoryDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminHistoryViewPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.14,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/ready_bg.png'),
                  fit: BoxFit.cover,
                ),
                color: Colors.amber[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 30, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Dashboard()),
                        );
                      },
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text(
                        'Approvals',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // TabBar Section for Approval and History tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isApprovalSelected = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: _isApprovalSelected ? Colors.amber : Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_view_rounded, size: 24, color: _isApprovalSelected ? Colors.white : Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Approval',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isApprovalSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1), // Add a small gap between the two tabs
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isApprovalSelected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: !_isApprovalSelected ? Colors.amber : Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 24, color: !_isApprovalSelected ? Colors.white : Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'History',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_isApprovalSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            // ListView section for displaying approval items
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.all(16.0),
                children: _isApprovalSelected
                    ? approvalItems
                    .map((item) => _buildApprovalCard(item))
                    .toList()
                    : historyItems
                    .map((item) => _buildHistoryCard(item))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _openApprovalDetail(item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_getStatusIcon(item['status']),
                  color: _getStatusColor(item['status']), size: 36),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['requestor_name'] ?? 'No Name',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Reason: ${item['take_leave_reason'] ?? 'No Reason Provided'}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'From: ${item['take_leave_from'] ?? 'N/A'} To: ${item['take_leave_to'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status']),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            item['status'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              CircleAvatar(
                backgroundImage: item['img_name'] != null
                    ? NetworkImage(item['img_name'])
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
                radius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _openHistoryDetail(item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_getStatusIcon(item['status']),
                  color: _getStatusColor(item['status']), size: 36),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['requestor_name'] ?? 'No Name',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Room: ${item['room_name'] ?? 'No Room Info'}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'From: ${item['take_leave_from']} To: ${item['take_leave_to']}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status']),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            item['status'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              CircleAvatar(
                backgroundImage: NetworkImage(item['img_name']),
                radius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
