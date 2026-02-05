import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/location_util.dart';

mixin InquiriesPageMixin<T extends StatefulWidget> on State<T> {
  List<Inquiry> get inquiries;
  set inquiries(List<Inquiry> value);

  bool get loading;
  set loading(bool value);

  Dio get dio;

  void refresh() {
    // Only refresh if not already loading
    if (!loading) {
      setState(() {
        loading = true;
      });
      LocationUtil.getCurrentLocation().then((position) {
        _loadInquiries(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _loadInquiries(double latitude, double longitude) async {
    try {
      final value = await ApiService(dio).getInquiries(
        latitude, 
        longitude
      );
      setState(() {
        inquiries = value;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(super.context).showSnackBar(
        SnackBar(content: Text('A network error occurred. Please try again later.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(super.context).showSnackBar(
        SnackBar(content: Text('Error fetching inquiries: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

}